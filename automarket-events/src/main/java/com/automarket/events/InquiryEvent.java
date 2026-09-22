package com.automarket.events;

import java.util.UUID;

/**
 * Events published by inquiry-service.
 */
public class InquiryEvent {

    public static final String SENT = "inquiry.sent";
    public static final String REPLIED = "inquiry.replied";

    /**
     * A buyer opened a thread on a listing. Only the first message of a conversation
     * produces this — every message after it, from either side, is a {@link Replied}.
     *
     * <p>{@code inquiryId} is the id of the message that opened the thread; it kept
     * its name because consumers outside this repository may still switch on it.
     */
    public record Sent(
            UUID inquiryId,
            UUID conversationId,
            UUID listingId,
            String listingTitle,
            UUID senderId,
            String senderName,
            String senderEmail,
            UUID sellerId,
            String sellerEmail,
            String message
    ) {}

    /**
     * A message in an existing thread, from either participant — so the recipient is
     * named explicitly rather than assumed to be the seller.
     */
    public record Replied(
            UUID messageId,
            UUID conversationId,
            UUID listingId,
            String listingTitle,
            UUID senderId,
            String senderName,
            UUID recipientId,
            String recipientEmail,
            String message
    ) {}
}
