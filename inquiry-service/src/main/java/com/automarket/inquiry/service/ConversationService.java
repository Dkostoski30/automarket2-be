package com.automarket.inquiry.service;

import com.automarket.common.dto.PageResponse;
import com.automarket.common.exception.BusinessRuleException;
import com.automarket.common.exception.ResourceNotFoundException;
import com.automarket.inquiry.dto.ConversationDetailDto;
import com.automarket.inquiry.dto.ConversationDto;
import com.automarket.inquiry.dto.MessageDto;
import com.automarket.inquiry.entity.Conversation;
import com.automarket.inquiry.entity.ListingView;
import com.automarket.inquiry.entity.Message;
import com.automarket.inquiry.entity.UserView;
import com.automarket.inquiry.repository.ConversationRepository;
import com.automarket.inquiry.repository.ListingViewRepository;
import com.automarket.inquiry.repository.MessageRepository;
import com.automarket.inquiry.repository.UserViewRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Threaded messaging between a buyer and the seller of one listing.
 *
 * <p>Replaces the one-shot inquiry flow: the first message from a buyer opens a
 * thread, and everything after it — from either side — appends to that thread.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ConversationService {

    /** Enough of the newest message to render an inbox row without loading it. */
    private static final int PREVIEW_LENGTH = 200;

    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final ListingViewRepository listingViewRepository;
    private final UserViewRepository userViewRepository;
    private final EventPublisher eventPublisher;

    /**
     * "Contact seller" from a listing page. Opens the thread for this (listing,
     * buyer) pair the first time and appends to it afterwards, so a buyer asking a
     * second question does not end up with a second thread.
     */
    @Transactional
    public ConversationDto startOrAppend(UUID listingId, String body, String senderEmail) {
        UserView sender = getUserOrThrow(senderEmail);
        ListingView listing = listingViewRepository.findById(listingId)
                .orElseThrow(() -> new ResourceNotFoundException("Listing", listingId));

        if (!listing.isApproved()) {
            throw new BusinessRuleException("Cannot inquire about an unapproved listing");
        }
        if (listing.getSellerId().equals(sender.getId())) {
            throw new BusinessRuleException("Cannot inquire about your own listing");
        }

        UserView seller = userViewRepository.findById(listing.getSellerId())
                .orElseThrow(() -> new ResourceNotFoundException("User", listing.getSellerId()));

        Conversation conversation = conversationRepository
                .findByListingIdAndBuyerId(listingId, sender.getId())
                .orElse(null);

        boolean opensThread = conversation == null;
        if (opensThread) {
            conversation = conversationRepository.save(Conversation.builder()
                    .listingId(listingId)
                    .buyerId(sender.getId())
                    .sellerId(seller.getId())
                    .build());
        }

        Message message = append(conversation, sender, body);

        // A seller's first sight of a buyer is a different email from "you have a
        // reply", and notification-service already has a template for it.
        if (opensThread) {
            eventPublisher.publishInquirySent(
                    conversation.getId(), message.getId(), listing.getId(), listing.getTitle(),
                    sender.getId(), sender.getName(), sender.getEmail(),
                    seller.getId(), seller.getEmail(), body);
        } else {
            eventPublisher.publishReply(
                    conversation.getId(), message.getId(), listing.getId(), listing.getTitle(),
                    sender.getId(), sender.getName(),
                    seller.getId(), seller.getEmail(), body);
        }

        log.info("Message from {} on conversation {}", senderEmail, conversation.getId());
        return toDto(reload(conversation.getId()), sender.getId(),
                listing.getTitle(), seller.getName());
    }

    /** A reply from either participant in an existing thread. */
    @Transactional
    public MessageDto reply(UUID conversationId, String body, String senderEmail) {
        UserView sender = getUserOrThrow(senderEmail);
        Conversation conversation = getParticipantConversation(conversationId, sender.getId());

        ListingView listing = listingViewRepository.findById(conversation.getListingId())
                .orElseThrow(() -> new ResourceNotFoundException("Listing", conversation.getListingId()));

        UUID recipientId = conversation.counterpartOf(sender.getId());
        UserView recipient = userViewRepository.findById(recipientId)
                .orElseThrow(() -> new ResourceNotFoundException("User", recipientId));

        Message message = append(conversation, sender, body);

        eventPublisher.publishReply(
                conversation.getId(), message.getId(), listing.getId(), listing.getTitle(),
                sender.getId(), sender.getName(),
                recipient.getId(), recipient.getEmail(), body);

        log.info("Reply from {} on conversation {}", senderEmail, conversationId);
        return new MessageDto(message.getId(), sender.getId(), sender.getName(),
                message.getBody(), message.getCreatedAt(), true);
    }

    @Transactional(readOnly = true)
    public PageResponse<ConversationDto> listFor(String userEmail, int page, int size) {
        UserView user = getUserOrThrow(userEmail);
        Page<Conversation> conversations =
                conversationRepository.findForParticipant(user.getId(), PageRequest.of(page, size));

        Set<UUID> listingIds = conversations.stream()
                .map(Conversation::getListingId).collect(Collectors.toSet());
        Set<UUID> counterpartIds = conversations.stream()
                .map(c -> c.counterpartOf(user.getId())).collect(Collectors.toSet());

        Map<UUID, String> titles = listingViewRepository.findAllById(listingIds).stream()
                .collect(Collectors.toMap(ListingView::getId, ListingView::getTitle));
        Map<UUID, String> names = userViewRepository.findAllById(counterpartIds).stream()
                .collect(Collectors.toMap(UserView::getId, UserView::getName));

        return PageResponse.from(conversations, c -> toDto(c, user.getId(),
                titles.getOrDefault(c.getListingId(), "Unknown Listing"),
                names.getOrDefault(c.counterpartOf(user.getId()), "Unknown User")));
    }

    /**
     * One thread with a page of its messages. Reading does not clear the unread
     * counter — the client calls {@link #markRead} once the messages are on screen,
     * so prefetching a thread cannot silently mark it read.
     */
    @Transactional(readOnly = true)
    public ConversationDetailDto getThread(UUID conversationId, String userEmail, int page, int size) {
        UserView user = getUserOrThrow(userEmail);
        Conversation conversation = getParticipantConversation(conversationId, user.getId());

        UUID counterpartId = conversation.counterpartOf(user.getId());
        UserView counterpart = userViewRepository.findById(counterpartId).orElse(null);
        String counterpartName = counterpart != null ? counterpart.getName() : "Unknown User";
        String listingTitle = listingViewRepository.findById(conversation.getListingId())
                .map(ListingView::getTitle).orElse("Unknown Listing");

        // A thread has exactly two participants, so every sender name on the page is
        // one of these two — no per-message lookup.
        Map<UUID, String> names = new HashMap<>();
        names.put(user.getId(), user.getName());
        names.put(counterpartId, counterpartName);

        Pageable pageable = PageRequest.of(page, size);
        Page<Message> newestFirst =
                messageRepository.findByConversationIdOrderByCreatedAtDesc(conversationId, pageable);

        // Paged newest-first so page 0 is the bottom of the chat, then flipped so the
        // page itself reads top-to-bottom. See ConversationDetailDto.
        List<Message> chronological = new ArrayList<>(newestFirst.getContent());
        Collections.reverse(chronological);
        Page<Message> ordered = new PageImpl<>(chronological, pageable, newestFirst.getTotalElements());

        PageResponse<MessageDto> messages = PageResponse.from(ordered, m -> new MessageDto(
                m.getId(),
                m.getSenderId(),
                names.getOrDefault(m.getSenderId(), "Unknown User"),
                m.getBody(),
                m.getCreatedAt(),
                m.getSenderId().equals(user.getId())));

        return new ConversationDetailDto(
                toDto(conversation, user.getId(), listingTitle, counterpartName), messages);
    }

    @Transactional
    public void markRead(UUID conversationId, String userEmail) {
        UserView user = getUserOrThrow(userEmail);
        Conversation conversation = getParticipantConversation(conversationId, user.getId());

        if (conversation.isBuyer(user.getId())) {
            conversationRepository.clearBuyerUnread(conversationId);
        } else {
            conversationRepository.clearSellerUnread(conversationId);
        }
    }

    @Transactional(readOnly = true)
    public long unreadCount(String userEmail) {
        return conversationRepository.totalUnreadFor(getUserOrThrow(userEmail).getId());
    }

    // ─── Internals ───────────────────────────────────────────────────────────

    /**
     * Inserts the message and moves the thread header forward in the same
     * transaction, so an inbox row can never advertise a message that was rolled
     * back.
     */
    private Message append(Conversation conversation, UserView sender, String body) {
        Instant now = Instant.now();
        Message message = messageRepository.save(Message.builder()
                .conversationId(conversation.getId())
                .senderId(sender.getId())
                .body(body)
                .createdAt(now)
                .build());

        boolean senderIsBuyer = conversation.isBuyer(sender.getId());
        conversationRepository.recordMessage(
                conversation.getId(), now, preview(body),
                senderIsBuyer ? 0 : 1,
                senderIsBuyer ? 1 : 0);

        return message;
    }

    private Conversation getParticipantConversation(UUID conversationId, UUID userId) {
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResourceNotFoundException("Conversation", conversationId));

        // Not a 403: a non-participant should not be able to tell a thread that
        // exists from one that never did.
        if (!conversation.isParticipant(userId)) {
            throw new ResourceNotFoundException("Conversation", conversationId);
        }
        return conversation;
    }

    private Conversation reload(UUID id) {
        return conversationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Conversation", id));
    }

    private static String preview(String body) {
        String collapsed = body.strip().replaceAll("\\s+", " ");
        return collapsed.length() <= PREVIEW_LENGTH
                ? collapsed
                : collapsed.substring(0, PREVIEW_LENGTH);
    }

    private ConversationDto toDto(Conversation c, UUID viewerId, String listingTitle, String counterpartName) {
        return new ConversationDto(
                c.getId(),
                c.getListingId(),
                listingTitle,
                c.counterpartOf(viewerId),
                counterpartName,
                c.isBuyer(viewerId) ? "BUYER" : "SELLER",
                c.getLastMessagePreview(),
                c.getLastMessageAt(),
                c.unreadFor(viewerId));
    }

    private UserView getUserOrThrow(String email) {
        return userViewRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", email));
    }
}
