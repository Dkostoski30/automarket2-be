package com.automarket.messaging.outbox;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * Moves recorded events from the outbox table to Kafka.
 *
 * <p>Runs on a fixed delay rather than reacting to writes, so a broker outage simply
 * delays delivery instead of losing it - pending rows stay pending and are retried on
 * the next tick.
 *
 * <p>Delivery is at-least-once by construction: if the broker acknowledges a record
 * but this transaction then fails before the row is marked published, the event is
 * sent again. Consumers must deduplicate - see
 * {@link com.automarket.messaging.inbox.InboxGuard}.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OutboxRelay {

    private final OutboxRepository outboxRepository;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final ObjectMapper objectMapper;

    @Value("${spring.application.name}")
    private String serviceName;

    @Value("${automarket.outbox.batch-size:100}")
    private int batchSize;

    @Value("${automarket.outbox.send-timeout-seconds:10}")
    private int sendTimeoutSeconds;

    @Scheduled(
            fixedDelayString = "${automarket.outbox.poll-interval-ms:1000}",
            initialDelayString = "${automarket.outbox.initial-delay-ms:10000}")
    @Transactional
    public void relayPendingEvents() {
        List<OutboxEvent> batch = outboxRepository.claimPending(serviceName, batchSize);
        if (batch.isEmpty()) {
            return;
        }

        int sent = 0;
        for (OutboxEvent event : batch) {
            try {
                // Re-parse to a JsonNode so the configured JsonSerializer writes the
                // stored JSON as an object. Sending the raw String would publish a
                // double-encoded JSON string that consumers cannot read as an event.
                JsonNode payload = objectMapper.readTree(event.getPayload());

                kafkaTemplate.send(event.getTopic(), event.getEventKey(), payload)
                        .get(sendTimeoutSeconds, TimeUnit.SECONDS);

                event.setPublishedAt(Instant.now());
                event.setLastError(null);
                sent++;
            } catch (Exception e) {
                // Leave published_at null so the next tick retries this row.
                event.setAttempts(event.getAttempts() + 1);
                event.setLastError(truncate(e.getMessage()));
                log.warn("Outbox publish failed for event {} ({}), attempt {}: {}",
                        event.getId(), event.getEventType(), event.getAttempts(), e.getMessage());
            }
        }

        outboxRepository.saveAll(batch);
        if (sent > 0) {
            log.debug("Relayed {}/{} outbox events to Kafka", sent, batch.size());
        }
    }

    private static String truncate(String message) {
        if (message == null) {
            return null;
        }
        return message.length() <= 1000 ? message : message.substring(0, 1000);
    }
}
