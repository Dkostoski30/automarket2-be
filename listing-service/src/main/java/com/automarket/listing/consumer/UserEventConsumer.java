package com.automarket.listing.consumer;

import com.automarket.events.KafkaTopics;
import com.automarket.events.UserEvent;
import com.automarket.listing.entity.UserView;
import com.automarket.listing.repository.UserViewRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

/**
 * Keeps listing_user_view current from the user-events topic.
 *
 * <p>Richer than the other projections because listing-service needs more than a
 * display name: it enforces the free-tier listing cap from `plan`, and renders seller
 * contact details from `phone` and `cityName`.
 *
 * <p>The handler is a blind upsert, so no dedup table is required - applying the same
 * snapshot twice produces the same row.
 *
 * <p>Deletion is soft. Listing.seller is a JPA association onto this table, so
 * removing a row would break every listing that user ever posted.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class UserEventConsumer {

    private final UserViewRepository userViewRepository;
    private final ObjectMapper objectMapper;

    @KafkaListener(topics = KafkaTopics.USER_EVENTS, groupId = KafkaTopics.GROUP_LISTING)
    @Transactional
    public void handle(String message) throws Exception {
        JsonNode envelope = objectMapper.readTree(message);
        String eventType = envelope.path("eventType").asText();
        JsonNode payload = envelope.get("payload");
        UUID userId = UUID.fromString(payload.path("userId").asText());

        switch (eventType) {
            case UserEvent.REGISTERED, UserEvent.UPDATED -> upsert(userId, payload);
            case UserEvent.PLAN_CHANGED -> applyPlan(userId, payload.path("newPlan").asText());
            case UserEvent.DELETED, UserEvent.DISABLED -> softDelete(userId);
            default -> log.debug("Ignoring event type {}", eventType);
        }
    }

    private void upsert(UUID userId, JsonNode payload) {
        UserView view = load(userId);
        view.setEmail(payload.path("email").asText());
        view.setName(payload.path("name").asText());
        view.setPhone(payload.path("phone").asText(null));
        view.setCityName(payload.path("cityName").asText(null));
        view.setPlan(parsePlan(payload.path("plan").asText()));
        if (view.getCreatedAt() == null && payload.hasNonNull("createdAt")) {
            view.setCreatedAt(Instant.parse(payload.path("createdAt").asText()));
        }
        userViewRepository.save(view);
        log.debug("Projected user {} into listing_user_view", userId);
    }

    private void applyPlan(UUID userId, String newPlan) {
        UserView view = userViewRepository.findById(userId).orElse(null);
        if (view == null) {
            // The snapshot has not arrived yet. Dropping this is safe: it is keyed by
            // user id, so the registration event is on the same partition ahead of it,
            // and any later snapshot carries the current plan anyway.
            log.warn("plan-changed for unknown user {} - no projection yet", userId);
            return;
        }
        view.setPlan(parsePlan(newPlan));
        userViewRepository.save(view);
        log.info("User {} plan projected as {}", userId, newPlan);
    }

    private void softDelete(UUID userId) {
        userViewRepository.findById(userId).ifPresent(view -> {
            view.setDeletedAt(Instant.now());
            userViewRepository.save(view);
            log.info("User {} marked deleted in listing_user_view", userId);
        });
    }

    private UserView load(UUID userId) {
        return userViewRepository.findById(userId).orElseGet(() -> {
            UserView v = new UserView();
            v.setId(userId);
            return v;
        });
    }

    private UserView.Plan parsePlan(String plan) {
        try {
            return UserView.Plan.valueOf(plan.toUpperCase());
        } catch (IllegalArgumentException | NullPointerException e) {
            return UserView.Plan.FREE;
        }
    }
}
