package com.automarket.auth.messaging;

import com.automarket.events.EventEnvelope;
import com.automarket.events.KafkaTopics;
import com.automarket.events.UserEvent;
import com.automarket.messaging.outbox.OutboxEvent;
import com.automarket.messaging.outbox.OutboxRecorder;
import com.automarket.messaging.outbox.OutboxRelay;
import com.automarket.messaging.outbox.OutboxRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.transaction.support.TransactionTemplate;
import org.testcontainers.containers.KafkaContainer;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * End-to-end test of the transactional outbox: record inside a transaction, relay
 * to a real broker, mark published.
 *
 * <p>Covers the two things that are easy to get wrong and impossible to see from a
 * log line. First, the relay must set {@code published_at} only after the broker
 * acknowledges — otherwise a failed publish is silently forgotten. Second, the
 * stored JSON must be re-parsed before sending: handing the raw String to a
 * {@code JsonSerializer} publishes a double-encoded JSON string that every consumer
 * fails to read, which no producer-side assertion would catch.
 */
@SpringBootTest(properties = {
        "spring.kafka.listener.auto-startup=false",
        // The relay is driven directly from the test, not by its scheduler.
        "automarket.outbox.initial-delay-ms=3600000"
})
@Testcontainers
class OutboxRelayTest {

    @Container
    @ServiceConnection
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16-alpine")
                    // Creates the tables this service does not own but whose rows its
                    // projection backfill selects. See upstream-tables.sql.
                    .withInitScript("upstream-tables.sql");

    @Container
    @ServiceConnection
    static final KafkaContainer KAFKA =
            new KafkaContainer(DockerImageName.parse("confluentinc/cp-kafka:7.6.0"));

    @Autowired private OutboxRecorder recorder;
    @Autowired private OutboxRelay relay;
    @Autowired private OutboxRepository outboxRepository;
    @Autowired private TransactionTemplate tx;
    @Autowired private ObjectMapper objectMapper;

    @Test
    void relaysAPendingEventAndMarksItPublished() throws Exception {
        UUID userId = UUID.randomUUID();
        EventEnvelope<UserEvent.Registered> envelope = EventEnvelope.of(
                UserEvent.REGISTERED,
                new UserEvent.Registered(userId, "relay@test.local", "Relay Test",
                        "070000000", "Skopje", "FREE", Instant.now()));
        UUID eventId = UUID.fromString(envelope.eventId());

        tx.executeWithoutResult(status ->
                recorder.record(KafkaTopics.USER_EVENTS, userId.toString(), envelope));

        assertThat(pending(eventId).getPublishedAt())
                .as("recording must not publish — that is the whole point of the outbox")
                .isNull();

        relay.relayPendingEvents();

        assertThat(pending(eventId).getPublishedAt())
                .as("published_at is the relay's only record that the broker accepted it")
                .isNotNull();

        ConsumerRecord<String, String> record = readOne(KafkaTopics.USER_EVENTS);
        assertThat(record.key())
                .as("keying by aggregate id is what keeps per-user events ordered")
                .isEqualTo(userId.toString());

        JsonNode published = objectMapper.readTree(record.value());
        assertThat(published.isObject())
                .as("a double-encoded JSON string here would break every consumer")
                .isTrue();
        assertThat(published.path("eventType").asText()).isEqualTo(UserEvent.REGISTERED);
        assertThat(published.path("payload").path("email").asText()).isEqualTo("relay@test.local");
    }

    @Test
    void isANoOpWhenNothingIsPending() {
        // An empty batch must be a no-op rather than an error path, because this
        // runs once a second in every publisher service.
        relay.relayPendingEvents();

        assertThat(outboxRepository.countBySourceServiceAndPublishedAtIsNull("auth-service"))
                .isZero();
    }

    private OutboxEvent pending(UUID eventId) {
        return outboxRepository.findById(eventId).orElseThrow();
    }

    private ConsumerRecord<String, String> readOne(String topic) {
        Properties props = new Properties();
        props.putAll(Map.of(
                ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, KAFKA.getBootstrapServers(),
                ConsumerConfig.GROUP_ID_CONFIG, "outbox-relay-test-" + UUID.randomUUID(),
                ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest",
                ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false"));

        try (KafkaConsumer<String, String> consumer =
                     new KafkaConsumer<>(props, new StringDeserializer(), new StringDeserializer())) {
            consumer.subscribe(List.of(topic));
            ConsumerRecords<String, String> records = consumer.poll(Duration.ofSeconds(20));
            assertThat(records.count())
                    .as("expected exactly one record on %s", topic)
                    .isEqualTo(1);
            return records.iterator().next();
        }
    }
}
