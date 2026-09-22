package com.automarket.auth;

import com.automarket.auth.repository.UserRepository;
import com.automarket.messaging.outbox.OutboxEvent;
import com.automarket.messaging.outbox.OutboxRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.transaction.support.TransactionTemplate;
import org.testcontainers.containers.PostgreSQLContainer;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Boots auth-service, with its real application.yml, against a database that has
 * been through db/schema-split/cutover.sql.
 *
 * <p>SchemaSplitCutoverTest proves Flyway is satisfied after the cutover. This
 * proves the rest of the schema configuration: that Hibernate validates every
 * entity against the moved tables, and — the easy one to get wrong — that native
 * queries reach them too. {@code hibernate.default_schema} qualifies JPQL but not
 * native SQL, so the outbox claim query only finds {@code auth.outbox} because the
 * pool sets the search_path. Without {@code hikari.schema} it would query a
 * {@code public.outbox} that no longer exists.
 *
 * <p>The database is prepared before the context starts, which is why the
 * container is started by hand rather than by the Testcontainers extension.
 */
@SpringBootTest(properties = {
        "spring.kafka.bootstrap-servers=localhost:1",
        "spring.kafka.listener.auto-startup=false",
        "spring.kafka.admin.auto-create=false",
        "spring.kafka.admin.fail-fast=false",
        "spring.kafka.admin.operation-timeout=2s",
        "automarket.outbox.initial-delay-ms=3600000"
})
class AuthAfterCutoverBootTest {

    private static final PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>("postgres:16-alpine");
    private static final UUID USER_ID = UUID.randomUUID();
    private static final UUID PENDING_EVENT_ID = UUID.randomUUID();

    static {
        POSTGRES.start();
        try {
            String url = POSTGRES.getJdbcUrl();
            String user = POSTGRES.getUsername();
            String password = POSTGRES.getPassword();

            SchemaSplitFixture.migrateAllLegacy(url, user, password);
            try (Connection c = DriverManager.getConnection(url, user, password);
                 Statement s = c.createStatement()) {
                s.execute("INSERT INTO users (id, email, password_hash, name, created_at, updated_at)"
                        + " VALUES ('" + USER_ID + "', 'seller@automarket.com', 'x', 'Seller', now(), now())");
                s.execute("INSERT INTO outbox (id, source_service, topic, event_key, event_type, payload)"
                        + " VALUES ('" + PENDING_EVENT_ID + "', 'auth-service', 'automarket.user-events',"
                        + " '" + USER_ID + "', 'user.registered', '{}')");
            }
            SchemaSplitFixture.runCutover(url, user, password);
        } catch (Exception e) {
            throw new IllegalStateException("Could not prepare the cut-over database", e);
        }
    }

    @DynamicPropertySource
    static void datasource(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
        registry.add("spring.datasource.username", POSTGRES::getUsername);
        registry.add("spring.datasource.password", POSTGRES::getPassword);
    }

    @Autowired
    private JdbcTemplate jdbc;

    @Autowired
    private UserRepository users;

    @Autowired
    private OutboxRepository outbox;

    @Autowired
    private TransactionTemplate tx;

    @Test
    void pooledConnectionsSearchTheServiceSchema() {
        assertThat(jdbc.queryForObject("SELECT current_schema()", String.class)).isEqualTo("auth");
    }

    @Test
    void bootingDidNotRecreateAnythingInPublic() {
        // The failure the schema config must prevent: Flyway missing its history
        // table and re-running V1, which would leave empty tables here.
        assertThat(jdbc.queryForObject(
                "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public'",
                Integer.class)).isZero();
    }

    @Test
    void jpaReadsTheMovedTables() {
        assertThat(users.findByEmail("seller@automarket.com"))
                .get().extracting(u -> u.getId()).isEqualTo(USER_ID);
    }

    @Test
    void nativeOutboxClaimFindsTheEventThatMovedWithTheCutover() {
        List<OutboxEvent> claimed = tx.execute(status -> outbox.claimPending("auth-service", 10));

        assertThat(claimed).extracting(OutboxEvent::getId).containsExactly(PENDING_EVENT_ID);
    }
}
