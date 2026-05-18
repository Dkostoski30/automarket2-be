package com.automarket.notification.consumer;

import com.automarket.events.InquiryEvent;
import com.automarket.events.ListingEvent;
import com.automarket.events.RabbitConfig;
import com.automarket.notification.service.EmailNotificationService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationEventConsumer {

    private final EmailNotificationService emailService;
    private final ObjectMapper objectMapper;

    @RabbitListener(queues = RabbitConfig.QUEUE_NOTIFICATION)
    public void handle(Message message) {
        String routingKey = message.getMessageProperties().getReceivedRoutingKey();
        try {
            JsonNode envelope = objectMapper.readTree(message.getBody());
            JsonNode payload = envelope.get("payload");

            switch (routingKey) {
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
                    log.info("inquiry.sent: inquiry={} seller={}", event.inquiryId(), event.sellerEmail());
                    emailService.sendNewInquiry(event.sellerEmail(), event.listingTitle(), event.senderName());
                }
                default -> log.debug("Ignoring event with routing key: {}", routingKey);
            }
        } catch (Exception e) {
            log.error("Failed to process event with routing key {}: {}", routingKey, e.getMessage(), e);
            // Do not rethrow — message is acked to avoid poisoning the queue
        }
    }
}
