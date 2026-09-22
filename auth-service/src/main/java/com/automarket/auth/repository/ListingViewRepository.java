package com.automarket.auth.repository;

import com.automarket.auth.entity.ListingView;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ListingViewRepository extends JpaRepository<ListingView, UUID> {

    /**
     * Active listings for a seller — the same definition listing-service uses in
     * {@code countActiveBySellerId}: approved and not deleted. Deleted and rejected
     * listings have no row here, so approval is the only condition left to check.
     */
    long countBySellerIdAndApprovedIsTrue(UUID sellerId);
}
