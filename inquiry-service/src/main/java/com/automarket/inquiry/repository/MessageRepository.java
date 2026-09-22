package com.automarket.inquiry.repository;

import com.automarket.inquiry.entity.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface MessageRepository extends JpaRepository<Message, UUID> {

    /**
     * Newest first, so page 0 is the bottom of the chat and older pages are fetched
     * as the user scrolls up. ConversationService flips each page back into
     * chronological order before returning it.
     */
    Page<Message> findByConversationIdOrderByCreatedAtDesc(UUID conversationId, Pageable pageable);
}
