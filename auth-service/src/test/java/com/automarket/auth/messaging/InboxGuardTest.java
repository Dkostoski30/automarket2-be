package com.automarket.auth.messaging;

import com.automarket.events.KafkaTopics;
import com.automarket.events.UserEvent;
import com.automarket.messaging.inbox.InboxGuard;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.transaction.support.TransactionTemplate;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Consumer-side deduplication.
 *
 * <p>Delivery is at-least-once by construction — the relay re-sends any event whose
 * publication was acknowledged but not recorded — so a handler with effects beyond
 * its own state must not apply the same event twice. auth-service's subscription
 * consumer is the case in point: applying a plan change twice would publish a
 * second downstream event.
 *
 * <p>The per-group assertion matters as much as the duplicate one. The primary key
 * is (event_id, consumer_group) precisely so that two services can each process the
 * same event exactly once; a single-column key would have one service's progress
 * suppress another's.
 */
@SpringBootTest(properties = {
        "spring.kafka.bootstrap-servers=localhost:1",
        "spring.kafka.listener.auto-startup=false",
        "spring.kafka.admin.auto-create=false",
        "spring.kafka.admin.fail-fast=false",
        "spring.kafka.admin.operation-timeout=2s",
        "automarket.outbox.initial-delay-ms=3600000"
})
@Testcontainers
class InboxGuardTest {

    @Container
    @ServiceConnection
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16-alpine")
                    // Creates the tables this service does not own but whose rows its
                    // projection backfill selects. See upstream-tables.sql.
                    .withInitScript("upstream-tables.sql");

    @Autowired private InboxGuard guard;
    @Autowired private TransactionTemplate tx;

    @Test
    void suppressesASecondDeliveryOfTheSameEvent() {
        String eventId = UUID.randomUUID().toString();

        assertThat(guard.alreadyProcessed(eventId, KafkaTopics.GROUP_AUTH))
                .as("an unseen event must be processed")
                .isFalse();

        tx.executeWithoutResult(status ->
                guard.markProcessed(eventId, KafkaTopics.GROUP_AUTH, UserEvent.PLAN_CHANGED));

        assertThat(guard.alreadyProcessed(eventId, KafkaTopics.GROUP_AUTH))
                .as("a redelivery of the same event must be skipped")
                .isTrue();
    }

    @Test
    void tracksEachConsumerGroupIndependently() {
        String eventId = UUID.randomUUID().toString();

        tx.executeWithoutResult(status ->
                guard.markProcessed(eventId, KafkaTopics.GROUP_AUTH, UserEvent.PLAN_CHANGED));

        assertThat(guard.alreadyProcessed(eventId, KafkaTopics.GROUP_PAYMENT))
                .as("one group's progress must not suppress another group's")
                .isFalse();
    }

    @Test
    void rollsTheMarkerBackWithTheFailedTransaction() {
        String eventId = UUID.randomUUID().toString();

        try {
            tx.executeWithoutResult(status -> {
                guard.markProcessed(eventId, KafkaTopics.GROUP_AUTH, UserEvent.PLAN_CHANGED);
                throw new IllegalStateException("handler blew up after marking");
            });
        } catch (IllegalStateException expected) {
            // The handler failing is the scenario under test.
        }

        assertThat(guard.alreadyProcessed(eventId, KafkaTopics.GROUP_AUTH))
                .as("a marker that outlived its failed handler would drop the event for good")
                .isFalse();
    }
}
