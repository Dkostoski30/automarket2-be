package com.automarket.auth;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.jdbc.core.JdbcTemplate;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Boots auth-service against a real PostgreSQL.
 *
 * <p>This is the regression test for ISSUES.md #18: all five services migrate the
 * same shared schema, so each needs its own Flyway history table. With the default
 * {@code flyway_schema_history} the first service to start records its
 * {@code V1__baseline} and every other one then dies on a checksum mismatch,
 * permanently. Nothing caught that before, because nothing ran.
 *
 * <p>Loading the context is itself the second assertion: {@code ddl-auto: validate}
 * checks every mapped entity against a real table, projection read models included,
 * so a projection whose migration was forgotten fails here rather than in the cluster.
 *
 * <p>No broker is started. Listener startup is off and the admin client points at a
 * closed port so it gives up immediately instead of retrying for 30s.
 */
@SpringBootTest(properties = {
        "spring.kafka.bootstrap-servers=localhost:1",
        "spring.kafka.listener.auto-startup=false",
        "spring.kafka.admin.auto-create=false",
        "spring.kafka.admin.fail-fast=false",
        "spring.kafka.admin.operation-timeout=2s",
        // Keep the outbox relay's scheduled tick out of the test window.
        "automarket.outbox.initial-delay-ms=3600000"
})
@Testcontainers
class AuthSchemaMigrationTest {

    @Container
    @ServiceConnection
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16-alpine")
                    // Creates the tables this service does not own but whose rows its
                    // projection backfill selects. See upstream-tables.sql.
                    .withInitScript("upstream-tables.sql");

    @Autowired
    private JdbcTemplate jdbc;

    @Test
    void migratesIntoItsOwnFlywayHistoryTable() {
        Integer applied = jdbc.queryForObject(
                "SELECT count(*) FROM flyway_history_auth WHERE success", Integer.class);

        assertThat(applied)
                .as("auth-service must record its migrations in flyway_history_auth, not the shared default")
                .isNotNull()
                .isPositive();
    }

    @Test
    void doesNotWriteToTheSharedDefaultHistoryTable() {
        Integer present = jdbc.queryForObject(
                "SELECT count(*) FROM information_schema.tables "
                        + "WHERE table_name = 'flyway_schema_history'", Integer.class);

        assertThat(present)
                .as("a service writing to flyway_schema_history breaks every other service")
                .isZero();
    }
}
