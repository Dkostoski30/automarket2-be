package com.automarket.inquiry.consumer;

import com.automarket.events.KafkaTopics;
import com.automarket.events.ListingEvent;
import com.automarket.inquiry.entity.ListingView;
import com.automarket.inquiry.repository.ListingViewRepository;
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
 * Keeps inquiry_listing_view current from the listing-events topic.
 *
 * <p>inquiry-service needs a listing's title (to render an inquiry), its seller (to
 * authorise "mark as read") and its approval state (to refuse inquiries on unapproved
 * listings). All three arrive on the event.
 *
 * <p>Blind upsert, so no dedup table is needed. Deletion is soft - inquiries outlive
 * the listing they reference.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ListingEventConsumer {

    private final ListingViewRepository listingViewRepository;
    private final ObjectMapper objectMapper;

    @KafkaListener(topics = KafkaTopics.LISTING_EVENTS, groupId = KafkaTopics.GROUP_INQUIRY)
    @Transactional
    public void handle(String message) throws Exception {
        JsonNode envelope = objectMapper.readTree(message);
        String eventType = envelope.path("eventType").asText();
        JsonNode payload = envelope.get("payload");
        UUID listingId = UUID.fromString(payload.path("listingId").asText());

        switch (eventType) {
            case ListingEvent.CREATED, ListingEvent.UPDATED -> upsert(listingId, payload);
            case ListingEvent.APPROVED -> setApproval(listingId, payload, true);
            case ListingEvent.REJECTED -> setApproval(listingId, payload, false);
            case ListingEvent.DELETED -> softDelete(listingId);
            default -> log.debug("Ignoring event type {}", eventType);
        }
    }

    private void upsert(UUID listingId, JsonNode payload) {
        ListingView view = load(listingId);
        view.setTitle(payload.path("listingTitle").asText());
        view.setSellerId(UUID.fromString(payload.path("sellerId").asText()));
        view.setApproved(payload.path("approved").asBoolean(false));
        listingViewRepository.save(view);
        log.debug("Projected listing {} into inquiry_listing_view", listingId);
    }

    private void setApproval(UUID listingId, JsonNode payload, boolean approved) {
        ListingView view = load(listingId);
        // Approved/Rejected carry the title and seller too, so a moderation event that
        // arrives before the create event still produces a complete row.
        if (payload.hasNonNull("listingTitle")) {
            view.setTitle(payload.path("listingTitle").asText());
        }
        if (payload.hasNonNull("sellerId")) {
            view.setSellerId(UUID.fromString(payload.path("sellerId").asText()));
        }
        view.setApproved(approved);
        listingViewRepository.save(view);
        log.info("Listing {} projected as approved={}", listingId, approved);
    }

    private void softDelete(UUID listingId) {
        listingViewRepository.findById(listingId).ifPresent(view -> {
            view.setDeletedAt(Instant.now());
            listingViewRepository.save(view);
            log.info("Listing {} marked deleted in inquiry_listing_view", listingId);
        });
    }

    private ListingView load(UUID listingId) {
        return listingViewRepository.findById(listingId).orElseGet(() -> {
            ListingView v = new ListingView();
            v.setId(listingId);
            return v;
        });
    }
}
