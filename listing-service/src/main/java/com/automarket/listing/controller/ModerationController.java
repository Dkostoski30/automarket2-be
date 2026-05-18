package com.automarket.listing.controller;

import com.automarket.listing.dto.ListingDetailDto;
import com.automarket.listing.service.ListingModerationService;
import com.automarket.common.dto.PageResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/moderation")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasAnyRole('MODERATOR', 'ADMIN', 'SUPERADMIN')")
@Tag(name = "Moderation")
public class ModerationController {

    private final ListingModerationService moderationService;

    @GetMapping("/listings")
    @Operation(summary = "Get all listings pending approval")
    public PageResponse<ListingDetailDto> getPending(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return moderationService.getPendingListings(page, size);
    }

    @GetMapping("/listings/{id}")
    @Operation(summary = "Get a pending listing by ID")
    public ListingDetailDto getPendingById(@PathVariable UUID id) {
        return moderationService.getPendingById(id);
    }

    @PostMapping("/listings/{id}/approve")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Approve a listing")
    public void approve(
            @PathVariable UUID id,
            @AuthenticationPrincipal String email) {
        moderationService.approve(id, email);
    }

    @PostMapping("/listings/{id}/reject")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Reject a listing with optional reason")
    public void reject(
            @PathVariable UUID id,
            @RequestBody(required = false) Map<String, String> body,
            @AuthenticationPrincipal String email) {
        String reason = body != null ? body.get("reason") : null;
        moderationService.reject(id, reason, email);
    }
}
