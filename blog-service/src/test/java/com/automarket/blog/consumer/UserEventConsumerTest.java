package com.automarket.blog.consumer;

import com.automarket.blog.entity.AuthorView;
import com.automarket.blog.repository.AuthorRepository;
import com.automarket.events.EventEnvelope;
import com.automarket.events.UserEvent;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * The blog author projection, driven straight through the listener method.
 *
 * <p>blog-service deliberately has no inbox table: the handler is a blind upsert of
 * the snapshot carried on the event, so applying it twice is meant to be
 * indistinguishable from applying it once. That claim is load-bearing — it is the
 * reason this consumer is allowed to skip deduplication — so it is worth an
 * assertion rather than a comment.
 *
 * <p>No broker here on purpose. The handler takes the raw message String, so feeding
 * it directly tests the projection without the cost and flakiness of a container.
 */
@SpringBootTest(properties = {
        "spring.kafka.bootstrap-servers=localhost:1",
        "spring.kafka.listener.auto-startup=false",
        "spring.kafka.admin.auto-create=false",
        "spring.kafka.admin.fail-fast=false",
        "spring.kafka.admin.operation-timeout=2s"
})
@Testcontainers
class UserEventConsumerTest {

    @Container
    @ServiceConnection
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16-alpine")
                    // Creates the tables this service does not own but whose rows its
                    // projection backfill selects. See upstream-tables.sql.
                    .withInitScript("upstream-tables.sql");

    @Autowired private UserEventConsumer consumer;
    @Autowired private AuthorRepository authorRepository;
    @Autowired private ObjectMapper objectMapper;

    @Test
    void projectsARegisteredUserIntoTheAuthorView() throws Exception {
        UUID userId = UUID.randomUUID();

        consumer.handle(message(UserEvent.REGISTERED, userId, "author@test.local", "First Author"));

        AuthorView view = authorRepository.findById(userId).orElseThrow();
        assertThat(view.getEmail()).isEqualTo("author@test.local");
        assertThat(view.getName()).isEqualTo("First Author");
    }

    @Test
    void appliesTheSameEventTwiceWithoutDuplicating() throws Exception {
        UUID userId = UUID.randomUUID();
        String message = message(UserEvent.REGISTERED, userId, "dup@test.local", "Dup Author");

        consumer.handle(message);
        consumer.handle(message);

        assertThat(authorRepository.findAllById(List.of(userId)))
                .as("a redelivery must not create a second author row")
                .hasSize(1);
    }

    @Test
    void appliesAnUpdateOverTheExistingRow() throws Exception {
        UUID userId = UUID.randomUUID();

        consumer.handle(message(UserEvent.REGISTERED, userId, "before@test.local", "Before"));
        consumer.handle(message(UserEvent.UPDATED, userId, "after@test.local", "After"));

        AuthorView view = authorRepository.findById(userId).orElseThrow();
        assertThat(view.getName()).isEqualTo("After");
        assertThat(view.getEmail()).isEqualTo("after@test.local");
    }

    @Test
    void ignoresEventTypesItDoesNotProject() throws Exception {
        UUID userId = UUID.randomUUID();

        // user.disabled is not projected: historical posts keep showing their author.
        // It must return normally rather than throw, or the record would be retried
        // three times and then dead-lettered for no reason.
        consumer.handle(objectMapper.writeValueAsString(
                EventEnvelope.of(UserEvent.DISABLED, new UserEvent.Disabled(userId, "gone@test.local"))));

        assertThat(authorRepository.findById(userId)).isEmpty();
    }

    private String message(String eventType, UUID userId, String email, String name) throws Exception {
        UserEvent.Registered payload = new UserEvent.Registered(
                userId, email, name, "070000000", "Skopje", "FREE", Instant.now());
        return objectMapper.writeValueAsString(EventEnvelope.of(eventType, payload));
    }
}
