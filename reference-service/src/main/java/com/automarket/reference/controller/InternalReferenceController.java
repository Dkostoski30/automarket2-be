package com.automarket.reference.controller;

import com.automarket.reference.service.ReferenceService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

/**
 * Internal API — not exposed via the API Gateway.
 * Used by other microservices (listing-service, admin dashboard) via service-to-service calls.
 */
@RestController
@RequestMapping("/internal/reference")
@RequiredArgsConstructor
public class InternalReferenceController {

    private final ReferenceService referenceService;

    /**
     * Returns total number of car brands.
     * Used by listing-service/admin dashboard for stats.
     */
    @GetMapping("/brands/count")
    public Map<String, Long> getBrandCount() {
        return Map.of("count", referenceService.getBrandCount());
    }

    /**
     * Validates that a car brand with the given ID exists.
     * Called by listing-service when creating/updating a listing.
     */
    @GetMapping("/brands/{id}/exists")
    public Map<String, Boolean> brandExists(@PathVariable UUID id) {
        return Map.of("exists", referenceService.validateBrandExists(id));
    }
}
