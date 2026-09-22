package com.automarket.auth.consumer;

import com.automarket.auth.entity.ListingView;
import com.automarket.auth.repository.ListingViewRepository;
import com.automarket.events.KafkaTopics;
import com.automarket.events.ListingEvent;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * Keeps auth_listing_view current from the listing-events topic.
 *
 * <p>Closes ISSUES.md #28: the public seller profile reported zero listings for
 * everybody because the count lives in listing-service and nothing carried it across.
 * Rather than a synchronous call — the first in this codebase, and one that would put
 * a public page at the mercy of another service being up — auth-service projects the
 * two fields it needs and counts locally.
 *
 * <p>Every handler is a blind upsert or a delete by primary key, so no inbox dedup
 * table is needed: applying the same event twice produces the same row, and replaying
 * the topic rebuilds the table. Records are keyed by listing id, so per-listing
 * ordering is guaranteed and an {@code approved} event can never overtake the
 * {@code created} that introduced its seller.
 *
 * <p>Rejection is a removal, not a flag. {@code ListingModerationService.reject} soft-
 * deletes the listing, so a rejected listing is no more active than a deleted one.
 *
 * <p>Shares the auth-service consumer group with {@link SubscriptionEventConsumer} on a
 * different topic, which Kafka assigns per member subscription — the two never contend
 * for each other's partitions. With auto-offset-reset=earliest the group has no
 * committed offset on listing-events yet, so this listener replays the topic on first
 * start and rebuilds the projection over whatever V4's backfill seeded.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ListingEventConsumer {

    private final ListingViewRepository listingViewRepository;
    private final ObjectMapper objectMapper;

    @KafkaListener(topics = KafkaTopics.LISTING_EVENTS, groupId = KafkaTopics.GROUP_AUTH)
    @Transactional
    public void handle(String message) throws Exception {
        JsonNode envelope = objectMapper.readTree(message);
        String eventType = envelope.path("eventType").asText();
        JsonNode payload = envelope.get("payload");
        UUID listingId = UUID.fromString(payload.path("listingId").asText());

        switch (eventType) {
            case ListingEvent.CREATED, ListingEvent.UPDATED -> upsert(
                    listingId,
                    UUID.fromString(payload.path("sellerId").asText()),
                    payload.path("approved").asBoolean(false));

            // Approval carries no approved flag — the event type is the flag.
            case ListingEvent.APPROVED -> upsert(
                    listingId,
                    UUID.fromString(payload.path("sellerId").asText()),
                    true);

            case ListingEvent.REJECTED, ListingEvent.DELETED -> remove(listingId, eventType);

            default -> log.debug("Ignoring event type {}", eventType);
        }
    }

    private void upsert(UUID listingId, UUID sellerId, boolean approved) {
        listingViewRepository.save(new ListingView(listingId, sellerId, approved));
        log.debug("Projected listing {} (seller {}, approved {}) into auth_listing_view",
                listingId, sellerId, approved);
    }

    private void remove(UUID listingId, String eventType) {
        // deleteById on an absent row is a no-op in Spring Data, which is what a
        // replayed delete should be.
        listingViewRepository.deleteById(listingId);
        log.debug("Removed listing {} from auth_listing_view via {}", listingId, eventType);
    }
}
