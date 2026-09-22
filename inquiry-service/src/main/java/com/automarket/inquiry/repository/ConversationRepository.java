package com.automarket.inquiry.repository;

import com.automarket.inquiry.entity.Conversation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

public interface ConversationRepository extends JpaRepository<Conversation, UUID> {

    Optional<Conversation> findByListingIdAndBuyerId(UUID listingId, UUID buyerId);

    /**
     * The user's inbox, covering both roles: threads where they are the buyer and
     * threads on their own listings. Served by idx_conversations_buyer /
     * idx_conversations_seller.
     */
    @Query("SELECT c FROM Conversation c WHERE c.buyerId = :userId OR c.sellerId = :userId "
            + "ORDER BY c.lastMessageAt DESC")
    Page<Conversation> findForParticipant(@Param("userId") UUID userId, Pageable pageable);

    /**
     * Applies a new message to the thread header in one statement: moves it to the
     * top of the inbox and bumps the recipient's unread counter. Written as an
     * update query rather than through the entity so concurrent replies from the two
     * participants cannot overwrite each other's counter.
     */
    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("UPDATE Conversation c SET c.lastMessageAt = :at, c.lastMessagePreview = :preview, "
            + "c.buyerUnread = c.buyerUnread + :buyerDelta, "
            + "c.sellerUnread = c.sellerUnread + :sellerDelta "
            + "WHERE c.id = :id")
    int recordMessage(@Param("id") UUID id,
                      @Param("at") Instant at,
                      @Param("preview") String preview,
                      @Param("buyerDelta") int buyerDelta,
                      @Param("sellerDelta") int sellerDelta);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("UPDATE Conversation c SET c.buyerUnread = 0 WHERE c.id = :id")
    int clearBuyerUnread(@Param("id") UUID id);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("UPDATE Conversation c SET c.sellerUnread = 0 WHERE c.id = :id")
    int clearSellerUnread(@Param("id") UUID id);

    /** Total unread across both roles — the one number the navbar badge needs. */
    @Query("SELECT COALESCE(SUM(CASE WHEN c.buyerId = :userId THEN c.buyerUnread ELSE c.sellerUnread END), 0) "
            + "FROM Conversation c WHERE c.buyerId = :userId OR c.sellerId = :userId")
    long totalUnreadFor(@Param("userId") UUID userId);
}
