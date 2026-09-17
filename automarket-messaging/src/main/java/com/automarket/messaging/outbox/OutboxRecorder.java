package com.automarket.messaging.outbox;

import com.automarket.events.EventEnvelope;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.UUID;

/**
 * Records an event for publication, inside whatever transaction the caller is in.
 *
 * <p>Producers call this instead of KafkaTemplate. Nothing reaches the broker here -
 * the write lands in the outbox table and commits (or rolls back) atomically with the
 * business state change. {@link OutboxRelay} publishes it afterwards.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OutboxRecorder {

    private final OutboxRepository outboxRepository;
    private final ObjectMapper objectMapper;

    @Value("${spring.application.name}")
    private String serviceName;

    /**
     * @param topic    destination Kafka topic
     * @param key      message key - the aggregate id, for per-entity ordering
     * @param envelope the event to publish
     */
    public void record(String topic, String key, EventEnvelope<?> envelope) {
        String json;
        try {
            json = objectMapper.writeValueAsString(envelope);
        } catch (JsonProcessingException e) {
            // Serialization cannot succeed on a retry, so failing the caller's
            // transaction is correct: better no state change than a silent event loss.
            throw new IllegalStateException(
                    "Could not serialize event " + envelope.eventType(), e);
        }

        outboxRepository.save(OutboxEvent.builder()
                .id(UUID.fromString(envelope.eventId()))
                .sourceService(serviceName)
                .topic(topic)
                .eventKey(key)
                .eventType(envelope.eventType())
                .payload(json)
                .createdAt(Instant.now())
                .build());

        log.debug("Recorded {} to outbox (topic={}, key={})", envelope.eventType(), topic, key);
    }
}
