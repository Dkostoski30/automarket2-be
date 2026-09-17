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
 * Records inquiry events for publication to the inquiry-events topic, keyed by
 * inquiry id. Writes to the transactional outbox, not to Kafka directly.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EventPublisher {

    private final OutboxRecorder outboxRecorder;

    public void publishInquirySent(UUID inquiryId, UUID listingId, String listingTitle,
                                    UUID senderId, String senderName, String senderEmail,
                                    UUID sellerId, String sellerEmail, String message) {
        EventEnvelope<InquiryEvent.Sent> envelope = EventEnvelope.of(InquiryEvent.SENT,
                new InquiryEvent.Sent(
                        inquiryId, listingId, listingTitle,
                        senderId, senderName, senderEmail,
                        sellerId, sellerEmail, message));
        outboxRecorder.record(KafkaTopics.INQUIRY_EVENTS, inquiryId.toString(), envelope);
        log.debug("Recorded {} for inquiry {}", InquiryEvent.SENT, inquiryId);
    }
}
