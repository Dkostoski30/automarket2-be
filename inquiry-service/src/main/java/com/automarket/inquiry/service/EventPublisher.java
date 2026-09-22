package com.automarket.inquiry.service;

import com.automarket.events.EventEnvelope;
import com.automarket.events.InquiryEvent;
import com.automarket.events.KafkaTopics;
import com.automarket.messaging.outbox.OutboxRecorder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.UUID;

/**
 * Records inquiry events for publication to the inquiry-events topic. Writes to the
 * transactional outbox, not to Kafka directly.
 *
 * <p>Both events are keyed by conversation id, so every message in one thread lands
 * on the same partition and a reply can never be delivered before the message that
 * opened the thread.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EventPublisher {

    private final OutboxRecorder outboxRecorder;

    public void publishInquirySent(UUID conversationId, UUID messageId,
                                   UUID listingId, String listingTitle,
                                   UUID senderId, String senderName, String senderEmail,
                                   UUID sellerId, String sellerEmail, String message) {
        EventEnvelope<InquiryEvent.Sent> envelope = EventEnvelope.of(InquiryEvent.SENT,
                new InquiryEvent.Sent(
                        messageId, conversationId, listingId, listingTitle,
                        senderId, senderName, senderEmail,
                        sellerId, sellerEmail, message));
        outboxRecorder.record(KafkaTopics.INQUIRY_EVENTS, conversationId.toString(), envelope);
        log.debug("Recorded {} for conversation {}", InquiryEvent.SENT, conversationId);
    }

    public void publishReply(UUID conversationId, UUID messageId,
                             UUID listingId, String listingTitle,
                             UUID senderId, String senderName,
                             UUID recipientId, String recipientEmail, String message) {
        EventEnvelope<InquiryEvent.Replied> envelope = EventEnvelope.of(InquiryEvent.REPLIED,
                new InquiryEvent.Replied(
                        messageId, conversationId, listingId, listingTitle,
                        senderId, senderName,
                        recipientId, recipientEmail, message));
        outboxRecorder.record(KafkaTopics.INQUIRY_EVENTS, conversationId.toString(), envelope);
        log.debug("Recorded {} for conversation {}", InquiryEvent.REPLIED, conversationId);
    }
}
