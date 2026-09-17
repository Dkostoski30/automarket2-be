package com.automarket.listing.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

/**
 * Local read model of a user, owned by listing-service.
 *
 * <p>Previously mapped onto auth-service's `users` table. It now maps onto
 * listing_user_view, a table this service owns, kept current by UserEventConsumer
 * from the user-events topic.
 *
 * <p>The class name and getters are unchanged so callers need not care where the data
 * comes from - only `city` changed, from an association into the shared `cities` table
 * to a plain denormalised name carried on the event.
 *
 * <p>No longer @Immutable: the consumer writes it. Nothing else should.
 */
@Entity
@Table(name = "listing_user_view")
@Getter
@Setter
@NoArgsConstructor
public class UserView {

    @Id
    private UUID id;

    private String email;

    private String name;

    private String phone;

    /** Denormalised from the event - cities are reference data owned elsewhere. */
    @Column(name = "city_name")
    private String cityName;

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
