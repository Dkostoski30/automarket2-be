package com.automarket.listing.repository;

import com.automarket.listing.entity.Listing;
import com.automarket.listing.entity.ListingImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ListingImageRepository extends JpaRepository<ListingImage, UUID> {

    List<ListingImage> findByListingOrderByDisplayOrderAsc(Listing listing);

    int countByListing(Listing listing);
}
