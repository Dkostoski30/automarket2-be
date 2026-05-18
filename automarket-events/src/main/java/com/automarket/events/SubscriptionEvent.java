package com.automarket.events;

import java.util.UUID;

/**
 * Events published by payment-service about Stripe subscription changes.
 */
public class SubscriptionEvent {

    public static final String ACTIVATED  = "subscription.activated";
    public static final String CANCELLED  = "subscription.cancelled";

    public record Activated(UUID userId, String plan, String stripeSubscriptionId) {}
    public record Cancelled(UUID userId, String plan, String stripeSubscriptionId) {}
}
