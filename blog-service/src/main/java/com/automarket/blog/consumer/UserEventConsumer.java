package com.automarket.blog.consumer;

import com.automarket.events.KafkaTopics;
import com.automarket.events.UserEvent;
import com.automarket.blog.entity.AuthorView;
import com.automarket.blog.repository.AuthorRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * Keeps blog_author_view current from the user-events topic.
 *
 * <p>No inbox/dedup table is needed here: the handler is a blind upsert of the
 * snapshot carried on the event, so applying it twice produces the same row. Only
 * consumers with side effects beyond their own state - like auth-service publishing a
 * downstream event - need InboxGuard.
 *
 * <p>Deletions do not remove the row. Historical records should keep showing who the
 * user was.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class UserEventConsumer {

    private final AuthorRepository authorRepository;
    private final ObjectMapper objectMapper;

    @KafkaListener(topics = KafkaTopics.USER_EVENTS, groupId = KafkaTopics.GROUP_BLOG)
    @Transactional
    public void handle(String message) throws Exception {
        JsonNode envelope = objectMapper.readTree(message);
        String eventType = envelope.path("eventType").asText();
        JsonNode payload = envelope.get("payload");

        switch (eventType) {
            case UserEvent.REGISTERED, UserEvent.UPDATED -> upsert(payload);
            // Not a failure: an event type this projection does not care about must not
            // be retried or dead-lettered.
            default -> log.debug("Ignoring event type {}", eventType);
        }
    }

    private void upsert(JsonNode payload) {
        UUID userId = UUID.fromString(payload.path("userId").asText());
        AuthorView view = authorRepository.findById(userId).orElseGet(() -> {
            AuthorView v = new AuthorView();
            v.setId(userId);
            return v;
        });
        view.setEmail(payload.path("email").asText());
        view.setName(payload.path("name").asText());
        authorRepository.save(view);
        log.debug("Projected user {} into blog_author_view", userId);
    }
}
