package com.automarket.inquiry.dto;

import java.time.Instant;
import java.util.UUID;

/**
 * One row of the inbox, rendered from the point of view of the caller.
 *
 * <p>{@code counterpart*} is whoever the caller is talking to, and {@code role} is
 * the caller's own side of the thread — the client never has to compare ids against
 * the logged-in user to decide which name to show.
 */
public record ConversationDto(
        UUID id,
        UUID listingId,
        String listingTitle,
        UUID counterpartId,
        String counterpartName,
        /** BUYER when the caller started the thread, SELLER when it is their listing. */
        String role,
        String lastMessagePreview,
        Instant lastMessageAt,
        int unreadCount
) {}
