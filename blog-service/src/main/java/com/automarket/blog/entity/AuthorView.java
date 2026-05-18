package com.automarket.blog.entity;

import jakarta.persistence.*;
import lombok.Getter;
import org.hibernate.annotations.Immutable;

import java.util.UUID;

/**
 * Read-only JPA view of the users table for resolving author names.
 *
 * Phase 2 (current): blog-service shares the same PostgreSQL instance as the monolith,
 * so we can still read from the users table directly.
 *
 * Phase 4+ (after auth-service extraction): replace this with an AuthServiceClient
 * Feign call to GET /internal/users/{id} with Redis caching.
 */
@Entity
@Table(name = "users")
@Immutable
@Getter
public class AuthorView {

    @Id
    private UUID id;

    private String name;

    private String email;
}
