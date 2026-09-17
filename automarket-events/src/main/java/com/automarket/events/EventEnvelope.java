package com.automarket.events;

import java.time.Instant;
import java.util.UUID;

/**
 * Standard wrapper for all domain events published to Kafka.
 * Every event follows this shape for consistency and idempotency.
 */
public record EventEnvelope<T>(
        String eventId,
        String eventType,
        Instant timestamp,
        T payload
) {
    public static <T> EventEnvelope<T> of(String eventType, T payload) {
        return new EventEnvelope<>(
                UUID.randomUUID().toString(),
                eventType,
                Instant.now(),
                payload
        );
    }
}
