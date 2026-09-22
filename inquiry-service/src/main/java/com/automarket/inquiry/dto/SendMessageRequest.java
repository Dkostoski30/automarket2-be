package com.automarket.inquiry.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * A reply in an existing thread. Unlike {@link SendInquiryRequest}, which opens one,
 * there is no 10-character floor: "yes, still available" is a legitimate reply.
 */
public record SendMessageRequest(
        @NotBlank @Size(max = 2000) String body
) {}
