package com.automarket.dto.blog;

import java.util.UUID;

public record BlogAuthorDto(
        UUID id,
        String name
) {}
