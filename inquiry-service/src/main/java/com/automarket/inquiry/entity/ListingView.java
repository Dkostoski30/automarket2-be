package com.automarket.inquiry.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

/**
 * Local read model of a listing, owned by inquiry-service.
 *
 * <p>Previously mapped onto listing-service's `listings` table. It now maps onto
 * inquiry_listing_view, kept current by ListingEventConsumer from the listing-events
 * topic.
 *
 * <p>Deletion is soft: inquiries outlive the listing they were sent about, and the
 * received/sent views still need its title.
 */
@Entity
@Table(name = "inquiry_listing_view")
@Getter
@Setter
@NoArgsConstructor
public class ListingView {

    @Id
    private UUID id;

    private String title;

    @Column(name = "seller_id")
    private UUID sellerId;

    private boolean approved;

    @Column(name = "deleted_at")
    private Instant deletedAt;
}
