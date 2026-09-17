package com.automarket.events;

import java.time.Instant;
import java.util.UUID;

/**
 * Events published by auth-service about user lifecycle changes.
 *
 * <p>Registered and Updated deliberately carry the user's full projectable state,
 * not just an id. Consumers keep a local read model of the users they need, so the
 * event has to carry enough to build one - this is event-carried state transfer.
 * The alternative (id-only events plus a callback to auth-service) would reintroduce
 * exactly the synchronous coupling the projections exist to remove.
 *
 * <p>Evolution policy is tolerant-reader: fields may be ADDED, never removed or
 * renamed. Consumers parse with Jackson and ignore what they do not recognise, so a
 * producer can ship a new field before any consumer knows about it.
 */
public class UserEvent {

    public static final String REGISTERED    = "user.registered";
    public static final String UPDATED       = "user.updated";
    public static final String DISABLED      = "user.disabled";
    public static final String DELETED       = "user.deleted";
    public static final String PLAN_CHANGED  = "user.plan-changed";

    /** Full snapshot at registration. */
    public record Registered(
            UUID userId,
            String email,
            String name,
            String phone,
            String cityName,
            String plan,
            Instant createdAt) {}

    /** Full snapshot after a profile change - same shape as Registered. */
    public record Updated(
            UUID userId,
            String email,
            String name,
            String phone,
            String cityName,
            String plan,
            Instant createdAt) {}

    public record Disabled(UUID userId, String email) {}

    public record Deleted(UUID userId, String email) {}

    public record PlanChanged(UUID userId, String oldPlan, String newPlan) {}
}
