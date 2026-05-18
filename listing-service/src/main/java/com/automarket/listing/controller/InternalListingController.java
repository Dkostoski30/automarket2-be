package com.automarket.listing.controller;

import com.automarket.listing.repository.ListingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/internal/listings")
@RequiredArgsConstructor
public class InternalListingController {

    private final ListingRepository listingRepository;

    @GetMapping("/count-by-user/{userId}")
    public Map<String, Long> countByUser(@PathVariable UUID userId) {
        return Map.of("count", listingRepository.countActiveBySellerId(userId));
    }

    @GetMapping("/stats")
    public Map<String, Long> getStats() {
        return Map.of(
                "pendingListings", listingRepository.countPendingApproval(),
                "approvedListings", listingRepository.countApproved()
        );
    }
}
