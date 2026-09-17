package com.automarket.events;

/**
 * Kafka topic names and consumer group ids for the AutoMarket event bus.
 *
 * <p>One topic per aggregate rather than per event type. The specific event is
 * carried in {@link EventEnvelope#eventType()}, so a consumer subscribes to an
 * aggregate's stream once and switches on the type inside.
 *
 * <p>Messages are keyed by aggregate id (user id, listing id, …). Kafka guarantees
 * ordering within a partition, and keying by aggregate id puts every event about
 * one entity on the same partition — so `user.plan-changed` can never be applied
 * out of order relative to `user.disabled` for the same user.
 *
 * <p>Consumer groups are per service. Unlike the previous RabbitMQ queue-and-binding
 * model, several services can read the same topic independently without extra
 * broker-side wiring: each group tracks its own offset.
 */
public final class KafkaTopics {

    private KafkaTopics() {}

    // ─── Topics ──────────────────────────────────────────────────────────────
    public static final String USER_EVENTS         = "automarket.user-events";
    public static final String LISTING_EVENTS      = "automarket.listing-events";
    public static final String INQUIRY_EVENTS      = "automarket.inquiry-events";
    public static final String SUBSCRIPTION_EVENTS = "automarket.subscription-events";

    /** Suffix applied by the dead-letter recoverer in {@link KafkaConfig}. */
    public static final String DLT_SUFFIX = "-dlt";

    public static final String USER_EVENTS_DLT         = USER_EVENTS + DLT_SUFFIX;
    public static final String LISTING_EVENTS_DLT      = LISTING_EVENTS + DLT_SUFFIX;
    public static final String INQUIRY_EVENTS_DLT      = INQUIRY_EVENTS + DLT_SUFFIX;
    public static final String SUBSCRIPTION_EVENTS_DLT = SUBSCRIPTION_EVENTS + DLT_SUFFIX;

    /** Consumer group for the dead-letter monitor. */
    public static final String GROUP_DLT_MONITOR = "dlt-monitor";

    // ─── Consumer groups (one per service) ───────────────────────────────────
    public static final String GROUP_NOTIFICATION = "notification-service";
    public static final String GROUP_AUTH         = "auth-service";
    public static final String GROUP_LISTING      = "listing-service";
    public static final String GROUP_BLOG         = "blog-service";
    public static final String GROUP_INQUIRY      = "inquiry-service";
    public static final String GROUP_PAYMENT      = "payment-service";
}
