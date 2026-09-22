package com.automarket.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Replaces the untyped {@code Map<String, String>} this endpoint used to take. A
 * request missing {@code newPassword} reached the encoder as null and came back a
 * 500, and nothing enforced the 8-character minimum that registration does — so the
 * password rule was only as strong as the path you set it through.
 */
public record ChangePasswordRequest(
        @NotBlank String currentPassword,
        @NotBlank @Size(min = 8, max = 100) String newPassword
) {}
