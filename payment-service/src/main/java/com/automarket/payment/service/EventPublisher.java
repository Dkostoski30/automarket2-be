package com.automarket.payment.service;

import com.automarket.events.EventEnvelope;
import com.automarket.events.RabbitConfig;
import com.automarket.events.SubscriptionEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class EventPublisher {

    private final RabbitTemplate rabbitTemplate;

    public void publishSubscriptionActivated(UUID userId, String plan, String stripeSubscriptionId) {
        SubscriptionEvent.Activated payload = new SubscriptionEvent.Activated(userId, plan, stripeSubscriptionId);
        EventEnvelope<SubscriptionEvent.Activated> envelope = EventEnvelope.of(SubscriptionEvent.ACTIVATED, payload);
        rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, SubscriptionEvent.ACTIVATED, envelope);
        log.debug("Published {} for user {}", SubscriptionEvent.ACTIVATED, userId);
    }

    public void publishSubscriptionCancelled(UUID userId, String plan, String stripeSubscriptionId) {
        SubscriptionEvent.Cancelled payload = new SubscriptionEvent.Cancelled(userId, plan, stripeSubscriptionId);
        EventEnvelope<SubscriptionEvent.Cancelled> envelope = EventEnvelope.of(SubscriptionEvent.CANCELLED, payload);
        rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, SubscriptionEvent.CANCELLED, envelope);
        log.debug("Published {} for user {}", SubscriptionEvent.CANCELLED, userId);
    }
}
