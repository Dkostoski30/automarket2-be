package com.automarket.events;

import java.util.UUID;

/**
 * Events published by auth-service about user lifecycle changes.
 */
public class UserEvent {

    public static final String REGISTERED    = "user.registered";
    public static final String DISABLED      = "user.disabled";
    public static final String DELETED       = "user.deleted";
    public static final String PLAN_CHANGED  = "user.plan-changed";

    public record Registered(UUID userId, String email, String fullName) {}
    public record Disabled(UUID userId, String email) {}
    public record Deleted(UUID userId, String email) {}
    public record PlanChanged(UUID userId, String oldPlan, String newPlan) {}
}
