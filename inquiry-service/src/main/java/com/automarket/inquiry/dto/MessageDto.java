package com.automarket.inquiry.dto;

import java.time.Instant;
import java.util.UUID;

public record MessageDto(
        UUID id,
        UUID senderId,
        String senderName,
        String body,
        Instant createdAt,
        /** True when the caller wrote this message — which side of the chat it sits on. */
        boolean mine
) {}
