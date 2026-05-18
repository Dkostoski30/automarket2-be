package com.automarket.payment.controller;

import com.automarket.payment.dto.CheckoutRequest;
import com.automarket.payment.service.SubscriptionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/subscriptions")
@RequiredArgsConstructor
public class SubscriptionController {

    private final SubscriptionService subscriptionService;

    @GetMapping("/plans")
    public Map<String, Object> getPlans() {
        return Map.of(
                "plans", List.of(
                        Map.of("id", "FREE", "name", "Free", "maxListings", 3, "price", 0,
                               "features", List.of("3 active listings", "Basic search", "Inquiries")),
                        Map.of("id", "PREMIUM", "name", "Premium", "maxListings", -1, "price", 1499,
                               "currency", "MKD", "billingPeriod", "monthly",
                               "features", List.of("Unlimited listings", "Featured listings",
                                       "Analytics dashboard", "Priority support"))
                )
        );
    }

    @PostMapping("/checkout")
    public Map<String, String> checkout(
            @Valid @RequestBody CheckoutRequest request,
            Authentication authentication) {
        String checkoutUrl = subscriptionService.createCheckoutSession(
                authentication.getName(), request.plan(),
                request.successUrl(), request.cancelUrl()
        );
        return Map.of("checkoutUrl", checkoutUrl);
    }
}
