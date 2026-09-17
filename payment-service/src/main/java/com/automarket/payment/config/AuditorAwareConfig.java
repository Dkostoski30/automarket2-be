package com.automarket.payment.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Optional;

/**
 * Supplies the @CreatedBy value for AuditableEntity.
 *
 * Without this — and without @EnableJpaAuditing on PaymentServiceApplication — the
 * @CreatedDate / @LastModifiedDate fields on Subscription stay null, and
 * subscriptions.created_at is NOT NULL with no database default, so every insert
 * fails at flush.
 *
 * Stripe webhooks arrive unauthenticated, so there is often no SecurityContext and
 * created_by is left null — that column is nullable, unlike the timestamps.
 */
@Configuration
public class AuditorAwareConfig {

    @Bean
    public AuditorAware<String> auditorAware() {
        return () -> Optional.ofNullable(SecurityContextHolder.getContext().getAuthentication())
                .filter(Authentication::isAuthenticated)
                .map(Authentication::getName);
    }
}
