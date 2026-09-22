package com.automarket.auth;

import org.flywaydb.core.Flyway;
import org.flywaydb.core.api.configuration.FluentConfiguration;
import org.yaml.snakeyaml.Yaml;

import java.io.IOException;
import java.io.Reader;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;
import java.util.Map;

/**
 * Builds databases the way the cluster builds them, for the schema-split tests.
 *
 * <p>Reads every service's migrations, its application.yml and db/schema-split from
 * the source tree by relative path, so these tests always exercise the files that
 * will actually be deployed and run.
 */
final class SchemaSplitFixture {

    static final String[] SERVICES = {"auth", "listing", "blog", "inquiry", "payment"};

    private SchemaSplitFixture() {
    }

    /**
     * A database as the releases before the split left it: all five services in the
     * shared public schema, in the order a concurrently-starting cluster converges to.
     * The backfills read across services — auth V3 reads cities, listing V4 reads
     * users, auth V4 reads listings — so neither auth nor listing can run to
     * completion first.
     */
    static void migrateAllLegacy(String url, String user, String password) {
        legacy(url, user, password, "listing", "3").migrate();
        legacy(url, user, password, "auth", "3").migrate();
        legacy(url, user, password, "listing", null).migrate();
        legacy(url, user, password, "auth", null).migrate();
        legacy(url, user, password, "blog", null).migrate();
        legacy(url, user, password, "inquiry", null).migrate();
        legacy(url, user, password, "payment", null).migrate();
    }

    /**
     * A fresh database under today's configuration, in the order the services
     * converge to: listing's reference data first, since auth V3 seeds from it;
     * then auth, which listing V4 needs.
     */
    static void migrateAllFresh(String url, String user, String password) {
        split(url, user, password, "listing").target("3").load().migrate();
        split(url, user, password, "auth").load().migrate();
        for (String svc : List.of("listing", "blog", "inquiry", "payment")) {
            split(url, user, password, svc).load().migrate();
        }
    }

    /**
     * The configuration before the split: shared public schema, per-service history
     * table, and none of today's callbacks — the old releases had none.
     */
    static Flyway legacy(String url, String user, String password, String svc, String target) {
        FluentConfiguration config = Flyway.configure()
                .dataSource(url, user, password)
                .locations(locations(svc))
                .table("flyway_history_" + svc)
                .baselineOnMigrate(true)
                .baselineVersion("0")
                .skipDefaultCallbacks(true);
        if (target != null) {
            config.target(target);
        }
        return config.load();
    }

    /**
     * Today's configuration, read from the service's own application.yml rather than
     * restated here — the point is to test what ships. The beforeEachMigrate
     * callback is picked up from the migration directory, as it is at runtime.
     */
    @SuppressWarnings("unchecked")
    static FluentConfiguration split(String url, String user, String password, String svc) {
        Map<String, Object> flyway;
        try (Reader in = Files.newBufferedReader(
                Path.of("../" + svc + "-service/src/main/resources/application.yml"))) {
            Map<String, Object> yml = new Yaml().load(in);
            flyway = (Map<String, Object>) ((Map<String, Object>) yml.get("spring")).get("flyway");
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        return Flyway.configure()
                .dataSource(url, user, password)
                .locations(locations(svc))
                .table((String) flyway.get("table"))
                .defaultSchema((String) flyway.get("default-schema"))
                .schemas((String) flyway.get("schemas"))
                .initSql(String.join("\n", (List<String>) flyway.get("init-sqls")))
                .baselineOnMigrate((Boolean) flyway.get("baseline-on-migrate"))
                .baselineVersion(String.valueOf(flyway.get("baseline-version")));
    }

    private static String locations(String svc) {
        return "filesystem:../" + svc + "-service/src/main/resources/db/migration";
    }

    /**
     * Runs db/schema-split/cutover.sql as {@code psql -v ON_ERROR_STOP=1} would: on a
     * fresh connection that is discarded afterwards, so a failed script leaves its
     * transaction aborted exactly as psql exiting would.
     */
    static void runCutover(String url, String user, String password) throws Exception {
        awaitNoOtherJdbcSessions(url, user, password);
        try (Connection c = DriverManager.getConnection(url, user, password);
             Statement s = c.createStatement()) {
            s.execute(Files.readString(Path.of("../db/schema-split/cutover.sql")));
        }
    }

    /**
     * Flyway and the fixtures close their connections before the cutover runs, but a
     * backend can outlive its client by a few milliseconds — long enough for the
     * cutover's own "services still connected" guard to see it.
     */
    private static void awaitNoOtherJdbcSessions(String url, String user, String password) throws Exception {
        try (Connection c = DriverManager.getConnection(url, user, password);
             Statement s = c.createStatement()) {
            for (int i = 0; i < 50; i++) {
                try (ResultSet rs = s.executeQuery("SELECT count(*) FROM pg_stat_activity"
                        + " WHERE datname = current_database() AND pid <> pg_backend_pid()"
                        + " AND application_name = 'PostgreSQL JDBC Driver'")) {
                    rs.next();
                    if (rs.getInt(1) == 0) {
                        return;
                    }
                }
                Thread.sleep(100);
            }
        }
    }
}
