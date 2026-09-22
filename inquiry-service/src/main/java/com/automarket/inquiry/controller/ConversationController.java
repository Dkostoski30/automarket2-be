package com.automarket.inquiry.controller;

import com.automarket.common.dto.PageResponse;
import com.automarket.inquiry.dto.ConversationDetailDto;
import com.automarket.inquiry.dto.ConversationDto;
import com.automarket.inquiry.dto.MessageDto;
import com.automarket.inquiry.dto.SendMessageRequest;
import com.automarket.inquiry.dto.UnreadCountDto;
import com.automarket.inquiry.service.ConversationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * The messaging inbox. Every endpoint is scoped to the caller: a thread is visible
 * only to its buyer and its seller, and both see the same thread from their own side.
 */
@RestController
@RequestMapping("/api/v1/conversations")
@RequiredArgsConstructor
public class ConversationController {

    private final ConversationService conversationService;

    /** The caller's threads across both roles, most recent activity first. */
    @GetMapping
    public PageResponse<ConversationDto> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return conversationService.listFor(currentUserEmail(), page, size);
    }

    /**
     * Declared before {@code /{id}} so the literal wins the match — otherwise the
     * path variable would be handed "unread-count" and fail UUID conversion.
     */
    @GetMapping("/unread-count")
    public UnreadCountDto unreadCount() {
        return new UnreadCountDto(conversationService.unreadCount(currentUserEmail()));
    }

    /**
     * One thread with a page of messages. Page 0 is the most recent messages; higher
     * pages are older. Reading does not mark anything read — call {@link #markRead}.
     */
    @GetMapping("/{id}")
    public ConversationDetailDto get(
            @PathVariable UUID id,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "30") int size) {
        return conversationService.getThread(id, currentUserEmail(), page, size);
    }

    @PostMapping("/{id}/messages")
    @ResponseStatus(HttpStatus.CREATED)
    public MessageDto reply(@PathVariable UUID id, @Valid @RequestBody SendMessageRequest request) {
        return conversationService.reply(id, request.body(), currentUserEmail());
    }

    @PostMapping("/{id}/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void markRead(@PathVariable UUID id) {
        conversationService.markRead(id, currentUserEmail());
    }

    private String currentUserEmail() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication.getName();
    }
}
