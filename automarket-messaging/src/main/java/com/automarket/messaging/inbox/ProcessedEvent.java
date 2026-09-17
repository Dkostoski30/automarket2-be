package com.automarket.messaging.inbox;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;
import java.time.Instant;

/**
 * Record that one consumer group has already handled one event.
 *
 * <p>Kafka delivers at least once, and the outbox relay can legitimately re-send a
 * record whose publication was acknowledged but not marked. Handlers whose effects
 * are not naturally idempotent must therefore check this table first.
 */
@Entity
@Table(name = "processed_event")
@IdClass(ProcessedEvent.Key.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProcessedEvent {

    /** EventEnvelope.eventId. */
    @Id
    @Column(name = "event_id", nullable = false, length = 64)
    private String eventId;

    /** Consumer group, so two groups can each process the same event once. */
    @Id
    @Column(name = "consumer_group", nullable = false, length = 128)
    private String consumerGroup;

    @Column(name = "event_type", length = 128)
    private String eventType;

    @Column(name = "processed_at", nullable = false)
    private Instant processedAt;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @EqualsAndHashCode
    public static class Key implements Serializable {
        private String eventId;
        private String consumerGroup;
    }
}
