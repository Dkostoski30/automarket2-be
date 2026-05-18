package com.automarket.blog.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record BlogRequest(
        @NotBlank @Size(min = 5, max = 100) String title,
        @NotBlank @Size(max = 500) String excerpt,
        @NotBlank String content,
        String coverImageUrl,
        Boolean published
) {}
