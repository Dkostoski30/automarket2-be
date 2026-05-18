package com.automarket.listing.service;

import com.automarket.listing.dto.ListingDetailDto;
import com.automarket.listing.entity.Listing;
import com.automarket.listing.repository.ListingRepository;
import com.automarket.common.dto.PageResponse;
import com.automarket.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class ListingModerationService {

    private final ListingRepository listingRepository;
    private final ListingService listingService;
    private final EventPublisher eventPublisher;

    @Transactional(readOnly = true)
    public PageResponse<ListingDetailDto> getPendingListings(int page, int size) {
        var results = listingRepository.findPendingApproval(
                PageRequest.of(page, size, Sort.by("createdAt").ascending()));
        return PageResponse.from(results, listingService::toDetailDtoPublic);
    }

    @Transactional
    @CacheEvict(value = "listing-detail", allEntries = true)
    public void approve(UUID listingId, String moderatorEmail) {
        Listing listing = getListingOrThrow(listingId);
        listing.setApproved(true);
        listingRepository.save(listing);

        eventPublisher.publishListingApproved(
                listing.getId(),
                listing.getSeller().getId(),
                listing.getSeller().getEmail(),
                listing.getTitle());
        log.info("Listing {} approved by {}", listingId, moderatorEmail);
    }

    @Transactional
    public void reject(UUID listingId, String reason, String moderatorEmail) {
        Listing listing = getListingOrThrow(listingId);
        listing.softDelete();
        listingRepository.save(listing);

        eventPublisher.publishListingRejected(
                listing.getId(),
                listing.getSeller().getId(),
                listing.getSeller().getEmail(),
                listing.getTitle(),
                reason);
        log.info("Listing {} rejected by {} — reason: {}", listingId, moderatorEmail, reason);
    }

    @Transactional(readOnly = true)
    public ListingDetailDto getPendingById(UUID id) {
        Listing listing = getListingOrThrow(id);
        return listingService.toDetailDtoPublic(listing);
    }

    private Listing getListingOrThrow(UUID id) {
        return listingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Listing", id));
    }
}
