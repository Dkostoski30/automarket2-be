package com.automarket.dto.admin;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record AdminUserDto(
        UUID id,
        String email,
        String name,
        String phone,
        String cityName,
        String plan,
        List<String> roles,
        Instant createdAt,
        int totalListings,
        int activeListings,
        boolean enabled
) {}
