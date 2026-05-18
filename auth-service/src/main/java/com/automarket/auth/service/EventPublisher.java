package com.automarket.auth.service;

import com.automarket.events.EventEnvelope;
import com.automarket.events.RabbitConfig;
import com.automarket.events.UserEvent;
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

    public void publishUserRegistered(UUID userId, String email, String fullName) {
        UserEvent.Registered payload = new UserEvent.Registered(userId, email, fullName);
        EventEnvelope<UserEvent.Registered> envelope = EventEnvelope.of(UserEvent.REGISTERED, payload);
        rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, UserEvent.REGISTERED, envelope);
        log.debug("Published event {} for user {}", UserEvent.REGISTERED, userId);
    }

    public void publishUserDisabled(UUID userId, String email) {
        UserEvent.Disabled payload = new UserEvent.Disabled(userId, email);
        EventEnvelope<UserEvent.Disabled> envelope = EventEnvelope.of(UserEvent.DISABLED, payload);
        rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, UserEvent.DISABLED, envelope);
        log.debug("Published event {} for user {}", UserEvent.DISABLED, userId);
    }

    public void publishUserDeleted(UUID userId, String email) {
        UserEvent.Deleted payload = new UserEvent.Deleted(userId, email);
        EventEnvelope<UserEvent.Deleted> envelope = EventEnvelope.of(UserEvent.DELETED, payload);
        rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, UserEvent.DELETED, envelope);
        log.debug("Published event {} for user {}", UserEvent.DELETED, userId);
    }

    public void publishUserPlanChanged(UUID userId, String oldPlan, String newPlan) {
        UserEvent.PlanChanged payload = new UserEvent.PlanChanged(userId, oldPlan, newPlan);
        EventEnvelope<UserEvent.PlanChanged> envelope = EventEnvelope.of(UserEvent.PLAN_CHANGED, payload);
        rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, UserEvent.PLAN_CHANGED, envelope);
        log.debug("Published event {} for user {}", UserEvent.PLAN_CHANGED, userId);
    }
}
