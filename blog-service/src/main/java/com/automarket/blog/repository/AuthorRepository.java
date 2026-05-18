package com.automarket.blog.repository;

import com.automarket.blog.entity.AuthorView;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

/**
 * Read-only repository for looking up author info from the shared users table.
 * Phase 2 only — replaced by AuthServiceClient Feign call when auth-service is extracted.
 */
public interface AuthorRepository extends JpaRepository<AuthorView, UUID> {
    Optional<AuthorView> findByEmail(String email);
}
