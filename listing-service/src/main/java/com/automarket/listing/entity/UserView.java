package com.automarket.listing.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Immutable;

import java.time.Instant;
import java.util.UUID;

/**
 * Read-only JPA view of the users table for resolving seller information.
 *
 * During the shared-DB transition phase, listing-service reads directly from
 * the users table. After auth-service extraction (Phase 4+), this will be
 * replaced with Feign calls to GET /internal/users/{id} with Redis caching.
 */
@Entity
@Table(name = "users")
@Immutable
@Getter
@NoArgsConstructor
public class UserView {

    @Id
    private UUID id;

    private String email;

    private String name;

    private String phone;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "city_id")
    private CityView city;

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "plan")
    @Enumerated(EnumType.STRING)
    private Plan plan;

    @Column(name = "deleted_at")
    private Instant deletedAt;

    public enum Plan {
        FREE, PREMIUM
    }
}
