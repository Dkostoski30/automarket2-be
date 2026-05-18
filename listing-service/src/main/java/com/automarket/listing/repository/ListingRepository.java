package com.automarket.listing.repository;

import com.automarket.listing.entity.Listing;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ListingRepository extends JpaRepository<Listing, UUID>, JpaSpecificationExecutor<Listing> {

    Optional<Listing> findBySlug(String slug);

    boolean existsBySlug(String slug);

    @Query("SELECT l FROM Listing l WHERE l.seller.id = :sellerId")
    Page<Listing> findBySellerId(UUID sellerId, Pageable pageable);

    @Query("SELECT COUNT(l) FROM Listing l WHERE l.seller.id = :sellerId AND l.approved = true AND l.deletedAt IS NULL")
    long countActiveBySellerId(UUID sellerId);

    @Query("SELECT l FROM Listing l WHERE l.featured = true AND l.featuredUntil > CURRENT_TIMESTAMP AND l.approved = true ORDER BY l.featuredUntil DESC")
    List<Listing> findActiveFeatured();

    @Query("SELECT l FROM Listing l WHERE l.approved = false AND l.deletedAt IS NULL ORDER BY l.createdAt ASC")
    Page<Listing> findPendingApproval(Pageable pageable);

    @Query("SELECT COUNT(l) FROM Listing l WHERE l.approved = false AND l.deletedAt IS NULL")
    long countPendingApproval();

    @Query("SELECT COUNT(l) FROM Listing l WHERE l.approved = true AND l.deletedAt IS NULL")
    long countApproved();
}
