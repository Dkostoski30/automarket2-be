package com.automarket.notification.consumer;

import com.automarket.events.InquiryEvent;
import com.automarket.events.KafkaTopics;
import com.automarket.events.ListingEvent;
import com.automarket.notification.service.EmailNotificationService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

/**
 * Sends transactional email in response to domain events.
 *
 * <p>Subscribes to the listing and inquiry topics under the notification-service
 * consumer group. Other services can consume the same topics under their own
 * group without affecting this one.
 *
 * <p>Failures are NOT swallowed. A processing exception propagates so the
 * container's DefaultErrorHandler retries it (3 attempts, 2s apart) and then
 * routes the record to "<topic>-dlt" for inspection. Under the previous RabbitMQ
 * consumer a transient mail outage silently discarded the notification.
 *
 * <p>Unrecognised event types return normally rather than throwing — they are not
 * failures, and retrying them to the dead-letter topic would be noise.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationEventConsumer {

    private final EmailNotificationService emailService;
    private final ObjectMapper objectMapper;

    @KafkaListener(
            topics = {KafkaTopics.LISTING_EVENTS, KafkaTopics.INQUIRY_EVENTS},
            groupId = KafkaTopics.GROUP_NOTIFICATION)
    public void handle(String message) throws Exception {
        JsonNode envelope = objectMapper.readTree(message);
        String eventType = envelope.path("eventType").asText();
        JsonNode payload = envelope.get("payload");

        switch (eventType) {
            case ListingEvent.APPROVED -> {
                ListingEvent.Approved event = objectMapper.treeToValue(payload, ListingEvent.Approved.class);
                log.info("listing.approved: listing={} seller={}", event.listingId(), event.sellerEmail());
                emailService.sendListingApproved(event.sellerEmail(), event.listingTitle(), event.listingId().toString());
            }
            case ListingEvent.REJECTED -> {
                ListingEvent.Rejected event = objectMapper.treeToValue(payload, ListingEvent.Rejected.class);
                log.info("listing.rejected: listing={} seller={}", event.listingId(), event.sellerEmail());
                emailService.sendListingRejected(event.sellerEmail(), event.listingTitle(), event.reason());
            }
            case InquiryEvent.SENT -> {
                InquiryEvent.Sent event = objectMapper.treeToValue(payload, InquiryEvent.Sent.class);
                log.info("inquiry.sent: conversation={} seller={}", event.conversationId(), event.sellerEmail());
                emailService.sendNewInquiry(event.sellerEmail(), event.listingTitle(),
                        event.senderName(), event.conversationId());
            }
            case InquiryEvent.REPLIED -> {
                InquiryEvent.Replied event = objectMapper.treeToValue(payload, InquiryEvent.Replied.class);
                log.info("inquiry.replied: conversation={} recipient={}",
                        event.conversationId(), event.recipientEmail());
                emailService.sendConversationReply(event.recipientEmail(), event.listingTitle(),
                        event.senderName(), event.conversationId());
            }
            default -> log.debug("No handler for event type: {}", eventType);
        }
    }
}
