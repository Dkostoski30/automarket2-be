package com.automarket.auth.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

/**
 * Local read model of a listing, owned by auth-service.
 *
 * <p>Narrow on purpose: auth-service renders one number from listings, the
 * {@code totalListings} on a public seller profile. Anything beyond seller and
 * approval state belongs to listing-service and should stay there.
 *
 * <p>Kept current by {@link com.automarket.auth.consumer.ListingEventConsumer}.
 * Nothing else writes it.
 */
@Entity
@Table(name = "auth_listing_view")
@Getter
@Setter
@NoArgsConstructor
public class ListingView {

    @Id
    @Column(name = "listing_id")
    private UUID listingId;

    @Column(name = "seller_id", nullable = false)
    private UUID sellerId;

    @Column(nullable = false)
    private boolean approved;

    public ListingView(UUID listingId, UUID sellerId, boolean approved) {
        this.listingId = listingId;
        this.sellerId = sellerId;
        this.approved = approved;
    }
}
