package com.automarket.auth.dto;

import com.automarket.auth.entity.User;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

/**
 * The current user's own profile.
 *
 * <p>{@code cityId} accompanies {@code cityName} so an edit form can round-trip:
 * the name is what a profile page renders, but {@link UpdateProfileRequest} takes an
 * id, and without it here a client has no way to preselect the city it is about to
 * send back.
 */
public record UserDto(
        UUID id,
        String email,
        String name,
        String phone,
        UUID cityId,
        String cityName,
        User.Plan plan,
        Set<String> roles,
        Instant createdAt
) {}
