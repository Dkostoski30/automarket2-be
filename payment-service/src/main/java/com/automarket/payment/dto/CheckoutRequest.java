package com.automarket.payment.dto;

import jakarta.validation.constraints.NotBlank;

public record CheckoutRequest(
        @NotBlank String plan,       // PREMIUM
        String successUrl,
        String cancelUrl
) {}
