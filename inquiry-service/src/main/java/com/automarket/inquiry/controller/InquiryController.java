package com.automarket.inquiry.controller;

import com.automarket.inquiry.dto.ConversationDto;
import com.automarket.inquiry.dto.SendInquiryRequest;
import com.automarket.inquiry.service.ConversationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

/**
 * "Contact seller" from a listing page — the one entry point that addresses a
 * listing rather than an existing thread.
 *
 * <p>Everything after the first message lives under
 * {@link ConversationController}: this endpoint only has to answer "which thread did
 * that land in", which is what it returns.
 *
 * <p>The former {@code /received}, {@code /sent} and {@code /{id}/read} endpoints
 * are gone. They described a mailbox of one-way messages, which no longer exists;
 * {@code GET /api/v1/conversations} replaces all three.
 */
@RestController
@RequestMapping("/api/v1/inquiries")
@RequiredArgsConstructor
public class InquiryController {

    private final ConversationService conversationService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ConversationDto send(@Valid @RequestBody SendInquiryRequest request) {
        return conversationService.startOrAppend(
                request.listingId(), request.message(), currentUserEmail());
    }

    private String currentUserEmail() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication.getName();
    }
}
