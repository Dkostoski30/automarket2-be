package com.automarket.messaging.outbox;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * A domain event durably recorded in the same database transaction as the state
 * change that produced it.
 *
 * <p>This is the transactional outbox pattern. Publishing to Kafka directly from
 * inside a transaction is a dual write: the database can commit while the publish
 * fails (nobody hears about a real change), or the publish can succeed while the
 * transaction rolls back (consumers act on state that never existed). Writing the
 * event to this table instead makes the state change and the intent to publish one
 * atomic unit; {@link OutboxRelay} then moves it to Kafka afterwards.
 *
 * <p>{@code sourceService} exists because all services currently share one schema,
 * so every relay must poll only its own rows. Once the schema-per-service split
 * lands the column is redundant, but harmless - which is why the table keeps its
 * plain name rather than being suffixed per service.
 */
@Entity
@Table(name = "outbox", indexes = {
        @Index(name = "idx_outbox_pending", columnList = "source_service, published_at, created_at")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OutboxEvent {

    /** Same value as EventEnvelope.eventId, so consumers can deduplicate on it. */
    @Id
    private UUID id;

    @Column(name = "source_service", nullable = false, length = 64)
    private String sourceService;

    @Column(nullable = false, length = 255)
    private String topic;

    /** Kafka message key - the aggregate id, so ordering per entity is preserved. */
    @Column(name = "event_key", nullable = false, length = 255)
    private String eventKey;

    @Column(name = "event_type", nullable = false, length = 128)
    private String eventType;

    /** The serialized EventEnvelope, stored verbatim and replayed as-is. */
    @Column(nullable = false, columnDefinition = "TEXT")
    private String payload;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    /** Null while pending. Set once the broker has acknowledged the record. */
    @Column(name = "published_at")
    private Instant publishedAt;

    @Column(nullable = false)
    @Builder.Default
    private int attempts = 0;

    @Column(name = "last_error", length = 1000)
    private String lastError;
}
