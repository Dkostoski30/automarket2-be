package com.automarket.auth.consumer;

import com.automarket.auth.repository.ListingViewRepository;
import com.automarket.events.EventEnvelope;
import com.automarket.events.ListingEvent;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * The seller listing-count projection, driven straight through the listener method.
 *
 * <p>This projection is what makes {@code totalListings} on a public seller profile a
 * real number instead of the hardcoded 0 of ISSUES.md #28, and like the other read
 * models here it has no inbox table: every handler is a blind upsert or a delete by
 * primary key, so a redelivery is meant to be indistinguishable from a single
 * delivery. That claim is what licenses skipping deduplication, so it gets an
 * assertion rather than a comment.
 *
 * <p>The count must track the same definition of "active" that listing-service
 * enforces in {@code countActiveBySellerId} — approved and not deleted — through
 * every transition a listing can make: created pending, approved, edited back into
 * moderation, rejected, deleted.
 *
 * <p>No broker here on purpose. The handler takes the raw message String, so feeding
 * it directly tests the projection without the cost and flakiness of a container.
 */
@SpringBootTest(properties = {
        "spring.kafka.bootstrap-servers=localhost:1",
        "spring.kafka.listener.auto-startup=false",
        "spring.kafka.admin.auto-create=false",
        "spring.kafka.admin.fail-fast=false",
        "spring.kafka.admin.operation-timeout=2s",
        "automarket.outbox.initial-delay-ms=3600000"
})
@Testcontainers
class ListingEventConsumerTest {

    @Container
    @ServiceConnection
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16-alpine")
                    .withInitScript("upstream-tables.sql");

    @Autowired private ListingEventConsumer consumer;
    @Autowired private ListingViewRepository listingViewRepository;
    @Autowired private ObjectMapper objectMapper;

    @Test
    void aPendingListingDoesNotCountYet() throws Exception {
        UUID seller = UUID.randomUUID();

        consumer.handle(created(UUID.randomUUID(), seller, false));

        assertThat(countFor(seller)).isZero();
    }

    @Test
    void approvalMakesAListingCount() throws Exception {
        UUID seller = UUID.randomUUID();
        UUID listing = UUID.randomUUID();

        consumer.handle(created(listing, seller, false));
        consumer.handle(approved(listing, seller));

        assertThat(countFor(seller)).isEqualTo(1);
    }

    @Test
    void anEditSendsAListingBackIntoModerationAndOutOfTheCount() throws Exception {
        UUID seller = UUID.randomUUID();
        UUID listing = UUID.randomUUID();

        consumer.handle(created(listing, seller, false));
        consumer.handle(approved(listing, seller));
        // ListingService.update sets approved=false, so the event carries false.
        consumer.handle(envelope(ListingEvent.UPDATED,
                new ListingEvent.Updated(listing, seller, "Edited", false)));

        assertThat(countFor(seller)).isZero();
    }

    @Test
    void rejectionRemovesAListingFromTheCount() throws Exception {
        UUID seller = UUID.randomUUID();
        UUID listing = UUID.randomUUID();

        consumer.handle(created(listing, seller, true));
        consumer.handle(envelope(ListingEvent.REJECTED,
                new ListingEvent.Rejected(listing, seller, "s@test.local", "Rejected", "blurry photos")));

        assertThat(countFor(seller)).isZero();
        assertThat(listingViewRepository.findById(listing)).isEmpty();
    }

    @Test
    void deletionRemovesAListingFromTheCount() throws Exception {
        UUID seller = UUID.randomUUID();
        UUID listing = UUID.randomUUID();

        consumer.handle(created(listing, seller, true));
        consumer.handle(envelope(ListingEvent.DELETED, new ListingEvent.Deleted(listing)));

        assertThat(countFor(seller)).isZero();
    }

    @Test
    void countsOnlyTheSellersOwnListings() throws Exception {
        UUID seller = UUID.randomUUID();
        UUID other = UUID.randomUUID();

        consumer.handle(created(UUID.randomUUID(), seller, true));
        consumer.handle(created(UUID.randomUUID(), seller, true));
        consumer.handle(created(UUID.randomUUID(), other, true));

        assertThat(countFor(seller)).isEqualTo(2);
        assertThat(countFor(other)).isEqualTo(1);
    }

    @Test
    void appliesTheSameEventTwiceWithoutDoubleCounting() throws Exception {
        UUID seller = UUID.randomUUID();
        String message = created(UUID.randomUUID(), seller, true);

        consumer.handle(message);
        consumer.handle(message);

        assertThat(countFor(seller))
                .as("a redelivery must not count the same listing twice")
                .isEqualTo(1);
    }

    @Test
    void aReplayedDeleteOfAnAbsentListingIsANoOp() throws Exception {
        // Must return normally rather than throw: the record would otherwise be
        // retried three times and dead-lettered for nothing.
        consumer.handle(envelope(ListingEvent.DELETED, new ListingEvent.Deleted(UUID.randomUUID())));
    }

    private long countFor(UUID sellerId) {
        return listingViewRepository.countBySellerIdAndApprovedIsTrue(sellerId);
    }

    private String created(UUID listingId, UUID sellerId, boolean approved) throws Exception {
        return envelope(ListingEvent.CREATED,
                new ListingEvent.Created(listingId, sellerId, "A car", approved));
    }

    private String approved(UUID listingId, UUID sellerId) throws Exception {
        return envelope(ListingEvent.APPROVED,
                new ListingEvent.Approved(listingId, sellerId, "s@test.local", "A car"));
    }

    private String envelope(String eventType, Object payload) throws Exception {
        return objectMapper.writeValueAsString(EventEnvelope.of(eventType, payload));
    }
}
