package com.automarket.listing.repository;

import com.automarket.listing.entity.Listing;
import com.automarket.listing.entity.ListingAnalytics;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ListingAnalyticsRepository extends JpaRepository<ListingAnalytics, UUID> {

    Optional<ListingAnalytics> findByListingAndDate(Listing listing, LocalDate date);

    List<ListingAnalytics> findByListingOrderByDateDesc(Listing listing);

    @Query("SELECT SUM(a.viewCount) FROM ListingAnalytics a WHERE a.listing = :listing")
    Long sumViewCountByListing(Listing listing);

    /**
     * Atomically increments today's view count, inserting the row if absent.
     *
     * <p>The previous read-modify-write in AnalyticsService lost updates under
     * concurrency: two simultaneous views both read the same count and both wrote
     * count+1. Doing it in one statement makes the increment safe, and
     * ON CONFLICT relies on the UNIQUE (listing_id, date) constraint from V1.
     */
    @Modifying
    @Query(value = "INSERT INTO listing_analytics "
            + "(id, listing_id, date, view_count, inquiry_count, favorite_count) "
            + "VALUES (gen_random_uuid(), :listingId, :date, 1, 0, 0) "
            + "ON CONFLICT (listing_id, date) "
            + "DO UPDATE SET view_count = listing_analytics.view_count + 1",
            nativeQuery = true)
    void incrementViewCount(@Param("listingId") UUID listingId, @Param("date") LocalDate date);
}
