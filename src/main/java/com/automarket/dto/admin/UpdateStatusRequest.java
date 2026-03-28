package com.automarket.dto.admin;

import jakarta.validation.constraints.NotNull;

public record UpdateStatusRequest(
        @NotNull Boolean enabled
) {}
