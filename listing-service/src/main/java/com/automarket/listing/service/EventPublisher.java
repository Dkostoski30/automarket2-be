package com.automarket.listing.service;

import com.automarket.events.EventEnvelope;
import com.automarket.events.KafkaTopics;
import com.automarket.events.ListingEvent;
import com.automarket.messaging.outbox.OutboxRecorder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.UUID;

/**
 * Records listing moderation events for publication to the listing-events topic,
 * keyed by listing id to preserve per-listing ordering.
 *
 * <p>Writes to the transactional outbox, not to Kafka directly - see OutboxRecorder.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EventPublisher {

    private final OutboxRecorder outboxRecorder;

    public void publishListingCreated(UUID listingId, UUID sellerId, String title, boolean approved) {
        record(listingId, EventEnvelope.of(ListingEvent.CREATED,
                new ListingEvent.Created(listingId, sellerId, title, approved)));
    }

    public void publishListingUpdated(UUID listingId, UUID sellerId, String title, boolean approved) {
        record(listingId, EventEnvelope.of(ListingEvent.UPDATED,
                new ListingEvent.Updated(listingId, sellerId, title, approved)));
    }

    public void publishListingDeleted(UUID listingId) {
        record(listingId, EventEnvelope.of(ListingEvent.DELETED,
                new ListingEvent.Deleted(listingId)));
    }

    public void publishListingApproved(UUID listingId, UUID sellerId, String sellerEmail, String listingTitle) {
        record(listingId, EventEnvelope.of(ListingEvent.APPROVED,
                new ListingEvent.Approved(listingId, sellerId, sellerEmail, listingTitle)));
    }

    public void publishListingRejected(UUID listingId, UUID sellerId, String sellerEmail, String listingTitle, String reason) {
        record(listingId, EventEnvelope.of(ListingEvent.REJECTED,
                new ListingEvent.Rejected(listingId, sellerId, sellerEmail, listingTitle, reason)));
    }

    private void record(UUID listingId, EventEnvelope<?> envelope) {
        outboxRecorder.record(KafkaTopics.LISTING_EVENTS, listingId.toString(), envelope);
        log.debug("Recorded event {} for listing {}", envelope.eventType(), listingId);
    }
}
