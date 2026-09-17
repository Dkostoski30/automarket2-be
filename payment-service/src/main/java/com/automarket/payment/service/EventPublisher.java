package com.automarket.payment.service;

import com.automarket.events.EventEnvelope;
import com.automarket.events.KafkaTopics;
import com.automarket.events.SubscriptionEvent;
import com.automarket.messaging.outbox.OutboxRecorder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.UUID;

/**
 * Records subscription events for publication to the subscription-events topic.
 *
 * <p>Writes to the transactional outbox. This matters most here: a Stripe webhook
 * that commits the subscription row but fails to publish would leave a paying
 * customer on the FREE plan with no trace of the intent to upgrade them.
 *
 * <p>Keyed by user id, not subscription id: activated and cancelled for the same user
 * must be applied in order, or a cancellation could be overtaken by a stale
 * activation and leave a non-paying user on PREMIUM.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EventPublisher {

    private final OutboxRecorder outboxRecorder;

    public void publishSubscriptionActivated(UUID userId, String plan, String stripeSubscriptionId) {
        record(userId, EventEnvelope.of(SubscriptionEvent.ACTIVATED,
                new SubscriptionEvent.Activated(userId, plan, stripeSubscriptionId)));
    }

    public void publishSubscriptionCancelled(UUID userId, String plan, String stripeSubscriptionId) {
        record(userId, EventEnvelope.of(SubscriptionEvent.CANCELLED,
                new SubscriptionEvent.Cancelled(userId, plan, stripeSubscriptionId)));
    }

    private void record(UUID userId, EventEnvelope<?> envelope) {
        outboxRecorder.record(KafkaTopics.SUBSCRIPTION_EVENTS, userId.toString(), envelope);
        log.debug("Recorded {} for user {}", envelope.eventType(), userId);
    }
}
