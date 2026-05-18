package com.automarket.events;

import java.util.UUID;

/**
 * Events published by inquiry-service.
 */
public class InquiryEvent {

    public static final String SENT = "inquiry.sent";

    public record Sent(
            UUID inquiryId,
            UUID listingId,
            String listingTitle,
            UUID senderId,
            String senderName,
            String senderEmail,
            UUID sellerId,
            String sellerEmail,
            String message
    ) {}
}
