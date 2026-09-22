package com.automarket.auth;

import org.flywaydb.core.api.output.MigrateResult;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Exercises the schema-per-service layout against the real migrations and the real
 * application.yml of all five services.
 *
 * <p>There are two ways a database reaches that layout, and they must end up the
 * same: a database from before the split goes through db/schema-split/cutover.sql
 * once; a fresh one is created by the services themselves. Each test starts from a
 * fresh pre-split database, migrated exactly as the old releases migrated it.
 *
 * <p>The assertion that matters most is in the happy path: after the cutover,
 * Flyway configured as the services now configure it must find its history and
 * execute <em>nothing</em>. If it executes anything, it has re-baselined into an
 * empty schema, which in production means every service boots against fresh empty
 * tables.
 *
 * <p>Lives in auth-service only because a test needs a module; see
 * {@link SchemaSplitFixture} for how it reaches the other services' files.
 */
@Testcontainers
class SchemaSplitCutoverTest {

    private static final String[] SERVICES = SchemaSplitFixture.SERVICES;
    private static final String[] PUBLISHERS = {"auth", "listing", "inquiry", "payment"};

    @Container
    static final PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>("postgres:16-alpine");

    private String url;
    private UUID userId;
    private UUID listingId;

    @BeforeEach
    void preSplitDatabaseMigratedLikeTheOldCluster() throws SQLException {
        url = newDatabase();
        SchemaSplitFixture.migrateAllLegacy(url, POSTGRES.getUsername(), POSTGRES.getPassword());
    }

    @Test
    void cutoverMovesEveryTableAndFlywayFindsItsHistory() throws Exception {
        seedConsistentData();

        cutover();

        for (String svc : SERVICES) {
            MigrateResult result = split(url, svc).migrate();
            assertThat(result.migrationsExecuted)
                    .as("%s: Flyway must find its moved history table and have nothing to do", svc)
                    .isZero();
            assertThat(split(url, svc).info().pending()).as("%s pending", svc).isEmpty();
        }

        try (Connection c = connect(url); Statement s = c.createStatement()) {
            assertThat(count(s, "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public'"))
                    .as("nothing left in public").isZero();
            assertThat(count(s, "SELECT count(*) FROM pg_constraint k"
                    + " JOIN pg_class a ON a.oid = k.conrelid JOIN pg_class b ON b.oid = k.confrelid"
                    + " WHERE k.contype = 'f' AND a.relnamespace <> b.relnamespace"))
                    .as("no foreign key crosses a service boundary").isZero();

            assertThat(count(s, "SELECT count(*) FROM auth.users WHERE id = '" + userId + "'")).isEqualTo(1);
            assertThat(count(s, "SELECT count(*) FROM listing.listings WHERE id = '" + listingId + "'")).isEqualTo(1);
            assertThat(count(s, "SELECT count(*) FROM listing.cities"))
                    .as("reference seed data moves with its table").isPositive();

            // Each publisher gets exactly its own event — including the undelivered
            // one, which is what makes the cutover lossless.
            for (String svc : PUBLISHERS) {
                assertThat(count(s, "SELECT count(*) FROM " + svc + ".outbox WHERE source_service = '" + svc + "-service'"))
                        .as("%s.outbox holds its own row", svc).isEqualTo(1);
                assertThat(count(s, "SELECT count(*) FROM " + svc + ".outbox WHERE source_service <> '" + svc + "-service'"))
                        .as("%s.outbox holds nobody else's", svc).isZero();
                assertThat(count(s, "SELECT count(*) FROM " + svc + ".processed_event")).isEqualTo(1);
            }
            assertThat(count(s, "SELECT count(*) FROM listing.outbox WHERE published_at IS NULL"))
                    .as("the pending event survives the move").isEqualTo(1);
        }
    }

    @Test
    void freshInstallBuildsTheSameLayoutAsTheCutover() throws Exception {
        cutover();

        String fresh = newDatabase();
        SchemaSplitFixture.migrateAllFresh(fresh, POSTGRES.getUsername(), POSTGRES.getPassword());

        assertThat(columns(fresh))
                .as("every table, column and type, per schema")
                .isEqualTo(columns(url));

        try (Connection c = connect(fresh); Statement s = c.createStatement()) {
            // The beforeEachMigrate callback is what lets auth V3 see listing.cities.
            // Without it the seed would find nothing — or fail — and registration
            // would reject every city.
            assertThat(count(s, "SELECT count(*) FROM auth.auth_city_view"))
                    .as("auth's city projection is seeded from listing's cities")
                    .isEqualTo(count(s, "SELECT count(*) FROM listing.cities"))
                    .isPositive();
        }
    }

    @Test
    void servicesRefuseToMigrateThePreSplitLayout() throws Exception {
        for (String svc : SERVICES) {
            assertThatThrownBy(() -> split(url, svc).migrate())
                    .as(svc)
                    .hasStackTraceContaining("shared public-schema layout");
        }
        assertUntouched();
    }

    @Test
    void abortsWithoutChangingAnythingOnAnUnownedOutboxRow() throws Exception {
        seedConsistentData();
        try (Connection c = connect(url); Statement s = c.createStatement()) {
            s.execute(insertOutbox("automarket-gateway", true));
        }

        assertThatThrownBy(this::cutover).hasMessageContaining("Unowned rows: 1 in outbox");

        assertUntouched();
    }

    @Test
    void refusesWhileAServiceIsConnected() throws Exception {
        // pgjdbc's default application_name is what a running service presents.
        try (Connection service = connect(url)) {
            assertThatThrownBy(this::cutover).hasMessageContaining("JDBC connection(s) still open");
        }
        assertUntouched();
    }

    @Test
    void refusesToRunTwice() throws Exception {
        seedConsistentData();
        cutover();

        assertThatThrownBy(this::cutover).hasMessageContaining("already run");
    }

    // ── Fixtures ────────────────────────────────────────────────────────────

    /** A user and a listing, fully projected, plus one outbox and inbox row per publisher. */
    private void seedConsistentData() throws SQLException {
        userId = UUID.randomUUID();
        listingId = UUID.randomUUID();
        try (Connection c = connect(url); Statement s = c.createStatement()) {
            s.execute(insertUser(userId, "seller@automarket.com"));
            for (String view : List.of("blog_author_view", "inquiry_user_view", "payment_user_view")) {
                s.execute("INSERT INTO " + view + " (id, email, name) VALUES ('" + userId
                        + "', 'seller@automarket.com', 'Seller')");
            }
            s.execute("INSERT INTO listing_user_view (id, email, name) VALUES ('" + userId
                    + "', 'seller@automarket.com', 'Seller')");

            s.execute("INSERT INTO listings (id, title, slug, description, price, seller_id, car_model,"
                    + " registration_year, kilometers, approved, created_at, updated_at) VALUES ('"
                    + listingId + "', 'Golf', 'golf-" + listingId + "', 'd', 1000, '" + userId
                    + "', 'Golf', 2015, 100000, true, now(), now())");
            s.execute("INSERT INTO inquiry_listing_view (id, title, seller_id, approved) VALUES ('"
                    + listingId + "', 'Golf', '" + userId + "', true)");
            s.execute("INSERT INTO auth_listing_view (listing_id, seller_id, approved) VALUES ('"
                    + listingId + "', '" + userId + "', true)");

            for (String svc : PUBLISHERS) {
                // listing's is left undelivered, to prove pending events move too.
                s.execute(insertOutbox(svc + "-service", !svc.equals("listing")));
                s.execute("INSERT INTO processed_event (event_id, consumer_group) VALUES ('"
                        + UUID.randomUUID() + "', '" + svc + "-service')");
            }
        }
    }

    private static String insertUser(UUID id, String email) {
        return "INSERT INTO users (id, email, password_hash, name, created_at, updated_at) VALUES ('"
                + id + "', '" + email + "', 'x', 'Seller', now(), now())";
    }

    private static String insertOutbox(String source, boolean published) {
        return "INSERT INTO outbox (id, source_service, topic, event_key, event_type, payload, published_at)"
                + " VALUES ('" + UUID.randomUUID() + "', '" + source + "', 'automarket.test', 'k', 'test', '{}', "
                + (published ? "now()" : "NULL") + ")";
    }

    private void assertUntouched() throws SQLException {
        try (Connection c = connect(url); Statement s = c.createStatement()) {
            assertThat(count(s, "SELECT count(*) FROM information_schema.schemata"
                    + " WHERE schema_name IN ('auth', 'listing', 'blog', 'inquiry', 'payment')"))
                    .as("no service schema created").isZero();
            assertThat(count(s, "SELECT count(*) FROM information_schema.tables"
                    + " WHERE table_schema = 'public' AND table_name = 'users'"))
                    .as("users still in public").isEqualTo(1);
        }
    }

    private static Set<String> columns(String db) throws SQLException {
        Set<String> out = new HashSet<>();
        try (Connection c = connect(db); Statement s = c.createStatement();
             ResultSet rs = s.executeQuery("SELECT table_schema, table_name, column_name, data_type, is_nullable"
                     + " FROM information_schema.columns"
                     + " WHERE table_schema NOT IN ('pg_catalog', 'information_schema')")) {
            while (rs.next()) {
                out.add(rs.getString(1) + "." + rs.getString(2) + "." + rs.getString(3)
                        + " " + rs.getString(4) + " null=" + rs.getString(5));
            }
        }
        return out;
    }

    private void cutover() throws Exception {
        SchemaSplitFixture.runCutover(url, POSTGRES.getUsername(), POSTGRES.getPassword());
    }

    private static org.flywaydb.core.Flyway split(String db, String svc) {
        return SchemaSplitFixture.split(db, POSTGRES.getUsername(), POSTGRES.getPassword(), svc).load();
    }

    private static String newDatabase() throws SQLException {
        String db = "cutover_" + UUID.randomUUID().toString().replace("-", "");
        try (Connection c = DriverManager.getConnection(
                POSTGRES.getJdbcUrl(), POSTGRES.getUsername(), POSTGRES.getPassword());
             Statement s = c.createStatement()) {
            s.execute("CREATE DATABASE " + db);
        }
        return "jdbc:postgresql://" + POSTGRES.getHost() + ":" + POSTGRES.getFirstMappedPort() + "/" + db;
    }

    private static Connection connect(String db) throws SQLException {
        return DriverManager.getConnection(db, POSTGRES.getUsername(), POSTGRES.getPassword());
    }

    private static int count(Statement s, String sql) throws SQLException {
        try (ResultSet rs = s.executeQuery(sql)) {
            rs.next();
            return rs.getInt(1);
        }
    }
}
