package com.automarket.auth.service;

import com.automarket.auth.entity.User;
import com.automarket.events.EventEnvelope;
import com.automarket.events.KafkaTopics;
import com.automarket.events.UserEvent;
import com.automarket.messaging.outbox.OutboxRecorder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.UUID;

/**
 * Records user lifecycle events for publication to the user-events topic.
 *
 * <p>Writes to the transactional outbox rather than to Kafka directly, so the event
 * and the state change that caused it commit or roll back together. OutboxRelay
 * performs the actual publish.
 *
 * <p>Registered and Updated carry the user's full projectable state: auth-service is
 * the only owner of user data, and every other service now keeps a local read model
 * built from these events instead of reading the users table.
 *
 * <p>Keyed by user id so every event about one user shares a partition and is
 * consumed in publication order - a plan change can never be applied after a later
 * deletion for the same user.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EventPublisher {

    private final OutboxRecorder outboxRecorder;

    public void publishUserRegistered(User user) {
        record(user.getId(), EventEnvelope.of(UserEvent.REGISTERED,
                new UserEvent.Registered(
                        user.getId(), user.getEmail(), user.getName(), user.getPhone(),
                        cityNameOf(user), user.getPlan().name(), user.getCreatedAt())));
    }

    public void publishUserUpdated(User user) {
        record(user.getId(), EventEnvelope.of(UserEvent.UPDATED,
                new UserEvent.Updated(
                        user.getId(), user.getEmail(), user.getName(), user.getPhone(),
                        cityNameOf(user), user.getPlan().name(), user.getCreatedAt())));
    }

    public void publishUserDisabled(UUID userId, String email) {
        record(userId, EventEnvelope.of(UserEvent.DISABLED,
                new UserEvent.Disabled(userId, email)));
    }

    public void publishUserDeleted(UUID userId, String email) {
        record(userId, EventEnvelope.of(UserEvent.DELETED,
                new UserEvent.Deleted(userId, email)));
    }

    public void publishUserPlanChanged(UUID userId, String oldPlan, String newPlan) {
        record(userId, EventEnvelope.of(UserEvent.PLAN_CHANGED,
                new UserEvent.PlanChanged(userId, oldPlan, newPlan)));
    }

    /** Cities are reference data owned by listing-service; consumers only need the name. */
    private static String cityNameOf(User user) {
        return user.getCity() != null ? user.getCity().getName() : null;
    }

    private void record(UUID userId, EventEnvelope<?> envelope) {
        outboxRecorder.record(KafkaTopics.USER_EVENTS, userId.toString(), envelope);
        log.debug("Recorded event {} for user {}", envelope.eventType(), userId);
    }
}
