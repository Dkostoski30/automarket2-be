package com.automarket.inquiry.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * A message thread between one buyer and the seller of one listing.
 *
 * <p>Identity is the pair (listing, buyer): the same buyer writing again about the
 * same car appends to this thread instead of opening another.
 *
 * <p>{@code buyerUnread} and {@code sellerUnread} are maintained by
 * {@link com.automarket.inquiry.repository.ConversationRepository#recordMessage}
 * rather than by dirty-checking this entity, so two people replying at once cannot
 * lose each other's increment.
 */
@Entity
@Table(name = "conversations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Conversation {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "listing_id", nullable = false)
    private UUID listingId;

    @Column(name = "buyer_id", nullable = false)
    private UUID buyerId;

    @Column(name = "seller_id", nullable = false)
    private UUID sellerId;

    @Column(name = "last_message_at", nullable = false)
    @Builder.Default
    private Instant lastMessageAt = Instant.now();

    @Column(name = "last_message_preview", columnDefinition = "TEXT")
    private String lastMessagePreview;

    @Column(name = "buyer_unread", nullable = false)
    @Builder.Default
    private int buyerUnread = 0;

    @Column(name = "seller_unread", nullable = false)
    @Builder.Default
    private int sellerUnread = 0;

    @Column(name = "created_at", nullable = false, updatable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    /** True when {@code userId} is the buyer; false when the seller. */
    public boolean isBuyer(UUID userId) {
        return buyerId.equals(userId);
    }

    public boolean isParticipant(UUID userId) {
        return buyerId.equals(userId) || sellerId.equals(userId);
    }

    /** The id of whoever is not {@code userId}. Caller must have checked participation. */
    public UUID counterpartOf(UUID userId) {
        return isBuyer(userId) ? sellerId : buyerId;
    }

    public int unreadFor(UUID userId) {
        return isBuyer(userId) ? buyerUnread : sellerUnread;
    }
}
