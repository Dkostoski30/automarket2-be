package com.automarket.events;

import java.util.UUID;

/**
 * Events published by listing-service about listing lifecycle changes.
 */
public class ListingEvent {

    public static final String APPROVED = "listing.approved";
    public static final String REJECTED = "listing.rejected";
    public static final String CREATED  = "listing.created";

    public record Approved(UUID listingId, UUID sellerId, String sellerEmail, String listingTitle) {}
    public record Rejected(UUID listingId, UUID sellerId, String sellerEmail, String listingTitle, String reason) {}
    public record Created(UUID listingId, UUID sellerId) {}
}
