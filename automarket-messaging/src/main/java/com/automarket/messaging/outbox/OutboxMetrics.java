package com.automarket.messaging.outbox;

import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.binder.MeterBinder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;

/**
 * Exposes outbox depth and staleness to Prometheus.
 *
 * <p>The outbox is the one place in this system where a silent failure is durable:
 * a relay that cannot reach the broker leaves rows pending forever, the publishing
 * service keeps serving traffic and returning 200s, and every consumer simply never
 * hears about the change. Nothing surfaces except a debug log on each tick.
 *
 * <p>Two gauges rather than one, because depth alone is ambiguous — a busy service
 * legitimately has rows in flight. Age is what separates "working" from "stopped":
 * {@code automarket_outbox_oldest_pending_seconds} should sit near the poll interval
 * and only grows when the relay is stuck.
 *
 * <p>Both are polled by Micrometer on scrape, so the queries run at the scrape
 * interval (10s) rather than per request. They are indexed by
 * {@code idx_outbox_pending}.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OutboxMetrics implements MeterBinder {

    private final OutboxRepository outboxRepository;

    @Value("${spring.application.name}")
    private String serviceName;

    @Override
    public void bindTo(MeterRegistry registry) {
        Gauge.builder("automarket.outbox.pending", this, OutboxMetrics::pendingCount)
                .description("Events recorded in the outbox that the relay has not yet published")
                .tag("service", serviceName)
                .register(registry);

        Gauge.builder("automarket.outbox.oldest.pending.seconds", this, OutboxMetrics::oldestPendingSeconds)
                .description("Age of the oldest unpublished outbox event; 0 when the outbox is drained")
                .baseUnit("seconds")
                .tag("service", serviceName)
                .register(registry);

        log.debug("Registered outbox gauges for {}", serviceName);
    }

    private double pendingCount() {
        return outboxRepository.countBySourceServiceAndPublishedAtIsNull(serviceName);
    }

    private double oldestPendingSeconds() {
        Instant oldest = outboxRepository.findOldestPendingCreatedAt(serviceName);
        if (oldest == null) {
            return 0d;
        }
        return Duration.between(oldest, Instant.now()).toMillis() / 1000d;
    }
}
