package com.automarket.inquiry.service;

import com.automarket.events.EventEnvelope;
import com.automarket.events.InquiryEvent;
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

    public void publishInquirySent(UUID inquiryId, UUID listingId, String listingTitle,
                                    UUID senderId, String senderName, String senderEmail,
                                    UUID sellerId, String sellerEmail, String message) {
        InquiryEvent.Sent payload = new InquiryEvent.Sent(
                inquiryId, listingId, listingTitle,
                senderId, senderName, senderEmail,
                sellerId, sellerEmail, message);
        EventEnvelope<InquiryEvent.Sent> envelope = EventEnvelope.of(InquiryEvent.SENT, payload);
        rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, InquiryEvent.SENT, envelope);
        log.debug("Published {} for inquiry {}", InquiryEvent.SENT, inquiryId);
    }
}
