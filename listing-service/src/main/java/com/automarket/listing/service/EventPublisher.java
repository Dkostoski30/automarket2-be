package com.automarket.listing.service;

import com.automarket.events.EventEnvelope;
import com.automarket.events.ListingEvent;
import com.automarket.events.RabbitConfig;
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

    public void publishListingApproved(UUID listingId, UUID sellerId, String sellerEmail, String listingTitle) {
        ListingEvent.Approved payload = new ListingEvent.Approved(listingId, sellerId, sellerEmail, listingTitle);
        EventEnvelope<ListingEvent.Approved> envelope = EventEnvelope.of(ListingEvent.APPROVED, payload);
        rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, ListingEvent.APPROVED, envelope);
        log.debug("Published event {} for listing {}", ListingEvent.APPROVED, listingId);
    }

    public void publishListingRejected(UUID listingId, UUID sellerId, String sellerEmail, String listingTitle, String reason) {
        ListingEvent.Rejected payload = new ListingEvent.Rejected(listingId, sellerId, sellerEmail, listingTitle, reason);
        EventEnvelope<ListingEvent.Rejected> envelope = EventEnvelope.of(ListingEvent.REJECTED, payload);
        rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, ListingEvent.REJECTED, envelope);
        log.debug("Published event {} for listing {}", ListingEvent.REJECTED, listingId);
    }
}
