package com.automarket.events;

import java.util.UUID;

/**
 * Events published by listing-service about listing lifecycle changes.
 *
 * <p>Created and Updated carry the listing's projectable state so consumers can keep
 * a local read model instead of reading the listings table. Approved and Rejected
 * additionally carry the seller's email because notification-service renders it into
 * an email; listing-service sources that from its own listing_user_view projection,
 * not from auth-service's tables.
 *
 * <p>Evolution policy is tolerant-reader: fields may be ADDED, never removed or
 * renamed.
 */
public class ListingEvent {

    public static final String CREATED  = "listing.created";
    public static final String UPDATED  = "listing.updated";
    public static final String APPROVED = "listing.approved";
    public static final String REJECTED = "listing.rejected";
    public static final String DELETED  = "listing.deleted";

    public record Created(UUID listingId, UUID sellerId, String listingTitle, boolean approved) {}

    public record Updated(UUID listingId, UUID sellerId, String listingTitle, boolean approved) {}

    public record Approved(UUID listingId, UUID sellerId, String sellerEmail, String listingTitle) {}

    public record Rejected(UUID listingId, UUID sellerId, String sellerEmail, String listingTitle, String reason) {}

    public record Deleted(UUID listingId) {}
}
