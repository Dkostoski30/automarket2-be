package com.automarket.listing.controller;

import com.automarket.listing.repository.ListingRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/dashboard")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasAnyRole('MODERATOR', 'ADMIN')")
@Tag(name = "Admin - Dashboard")
public class AdminDashboardController {

    private final ListingRepository listingRepository;

    @GetMapping
    @Operation(summary = "Get admin dashboard statistics")
    public Map<String, Object> getDashboard() {
        return Map.of(
                "pendingListings", listingRepository.countPendingApproval(),
                "approvedListings", listingRepository.countApproved()
        );
    }
}
