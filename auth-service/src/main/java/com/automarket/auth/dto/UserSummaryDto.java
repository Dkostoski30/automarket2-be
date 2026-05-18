package com.automarket.auth.dto;

import java.util.UUID;

/**
 * Lightweight user DTO for internal service-to-service communication.
 * Used by other services (blog-service, listing-service, etc.) to resolve user info.
 */
public record UserSummaryDto(
        UUID id,
        String name,
        String email,
        String phone,
        String cityName
) {}
