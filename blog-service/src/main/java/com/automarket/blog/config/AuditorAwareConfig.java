package com.automarket.blog.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Optional;

/**
 * Supplies the @CreatedBy value for AuditableEntity.
 *
 * Without this — and without @EnableJpaAuditing on BlogServiceApplication — the
 * @CreatedDate / @LastModifiedDate fields on Blog stay null, and blogs.created_at
 * is NOT NULL with no database default, so every insert fails at flush.
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
