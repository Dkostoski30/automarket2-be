package com.automarket.auth.consumer;

import com.automarket.auth.entity.User;
import com.automarket.auth.repository.UserRepository;
import com.automarket.auth.service.EventPublisher;
import com.automarket.events.KafkaTopics;
import com.automarket.events.SubscriptionEvent;
import com.automarket.messaging.inbox.InboxGuard;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * Applies billing outcomes to the user's plan.
 *
 * <p>This closes the loop that previously left paying customers on FREE:
 * payment-service recorded the subscription and published the event, but nothing
 * consumed it, so {@code users.plan} never changed and listing-service kept enforcing
 * the free-tier cap on someone who had paid.
 *
 * <p>The whole handler runs in one transaction, so the plan change, the inbox marker
 * and the outgoing user.plan-changed event commit together or not at all. On failure
 * the exception propagates to the container's DefaultErrorHandler, which retries and
 * then dead-letters the record rather than dropping it.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class SubscriptionEventConsumer {

    private final UserRepository userRepository;
    private final EventPublisher eventPublisher;
    private final InboxGuard inboxGuard;
    private final ObjectMapper objectMapper;

    @KafkaListener(
            topics = KafkaTopics.SUBSCRIPTION_EVENTS,
            groupId = KafkaTopics.GROUP_AUTH)
    @Transactional
    public void handle(String message) throws Exception {
        JsonNode envelope = objectMapper.readTree(message);
        String eventId = envelope.path("eventId").asText();
        String eventType = envelope.path("eventType").asText();
        JsonNode payload = envelope.get("payload");

        // Kafka delivers at least once, and the outbox relay may re-send a record it
        // published but failed to mark. Applying a plan change twice is harmless, but
        // re-publishing user.plan-changed each time is not.
        if (inboxGuard.alreadyProcessed(eventId, KafkaTopics.GROUP_AUTH)) {
            log.debug("Skipping already-processed event {} ({})", eventId, eventType);
            return;
        }

        switch (eventType) {
            case SubscriptionEvent.ACTIVATED -> {
                SubscriptionEvent.Activated event =
                        objectMapper.treeToValue(payload, SubscriptionEvent.Activated.class);
                applyPlan(event.userId(), parsePlan(event.plan()), eventType);
            }
            case SubscriptionEvent.CANCELLED -> {
                SubscriptionEvent.Cancelled event =
                        objectMapper.treeToValue(payload, SubscriptionEvent.Cancelled.class);
                applyPlan(event.userId(), User.Plan.FREE, eventType);
            }
            default -> {
                // Not a failure: an event type this service does not handle should not
                // be retried or dead-lettered.
                log.debug("No handler for event type: {}", eventType);
                return;
            }
        }

        inboxGuard.markProcessed(eventId, KafkaTopics.GROUP_AUTH, eventType);
    }

    private void applyPlan(UUID userId, User.Plan newPlan, String eventType) {
        User user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            // Nothing to apply and nothing a retry would fix, so do not throw: that
            // would burn the retry budget and dead-letter a record about a user who
            // no longer exists.
            log.warn("{} for unknown user {} - ignoring", eventType, userId);
            return;
        }

        User.Plan oldPlan = user.getPlan();
        if (oldPlan == newPlan) {
            log.debug("User {} already on plan {} - no change", userId, newPlan);
            return;
        }

        user.setPlan(newPlan);
        userRepository.save(user);

        // Recorded to the outbox in this same transaction. listing-service will consume
        // it once its projection exists; today it still reads users.plan directly.
        eventPublisher.publishUserPlanChanged(userId, oldPlan.name(), newPlan.name());

        log.info("User {} plan changed {} -> {} via {}", userId, oldPlan, newPlan, eventType);
    }

    private User.Plan parsePlan(String plan) {
        try {
            return User.Plan.valueOf(plan.toUpperCase());
        } catch (IllegalArgumentException | NullPointerException e) {
            log.warn("Unrecognised plan '{}' on subscription event - defaulting to FREE", plan);
            return User.Plan.FREE;
        }
    }
}
