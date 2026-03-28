package com.automarket.dto.blog;

import java.time.Instant;
import java.util.UUID;

public record BlogDto(
        UUID id,
        String title,
        String slug,
        String excerpt,
        String content,
        String coverImageUrl,
        BlogAuthorDto author,
        Boolean published,
        Instant createdAt,
        Instant updatedAt
) {}
