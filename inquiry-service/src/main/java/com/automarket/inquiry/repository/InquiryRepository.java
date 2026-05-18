package com.automarket.inquiry.repository;

import com.automarket.inquiry.entity.Inquiry;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.UUID;

public interface InquiryRepository extends JpaRepository<Inquiry, UUID> {

    Page<Inquiry> findBySenderIdOrderByCreatedAtDesc(UUID senderId, Pageable pageable);

    @Query("SELECT i FROM Inquiry i WHERE i.listingId IN " +
           "(SELECT l.id FROM ListingView l WHERE l.sellerId = :sellerId) " +
           "ORDER BY i.createdAt DESC")
    Page<Inquiry> findReceivedBySeller(UUID sellerId, Pageable pageable);
}
