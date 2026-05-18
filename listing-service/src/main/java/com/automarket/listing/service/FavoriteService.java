package com.automarket.listing.service;

import com.automarket.listing.dto.ListingDto;
import com.automarket.listing.entity.Favorite;
import com.automarket.listing.entity.Listing;
import com.automarket.listing.entity.UserView;
import com.automarket.listing.repository.FavoriteRepository;
import com.automarket.listing.repository.ListingRepository;
import com.automarket.listing.repository.UserViewRepository;
import com.automarket.common.dto.PageResponse;
import com.automarket.common.exception.BusinessRuleException;
import com.automarket.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final ListingRepository listingRepository;
    private final UserViewRepository userViewRepository;
    private final ListingService listingService;

    @Transactional
    public void add(UUID listingId, String userEmail) {
        UserView user = getUserOrThrow(userEmail);
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ResourceNotFoundException("Listing", listingId));

        if (favoriteRepository.existsByUserIdAndListing(user.getId(), listing)) {
            throw new BusinessRuleException("Listing already in favorites");
        }

        favoriteRepository.save(Favorite.builder().userId(user.getId()).listing(listing).build());
        log.debug("Favorite added: {} -> {}", userEmail, listingId);
    }

    @Transactional
    public void remove(UUID listingId, String userEmail) {
        UserView user = getUserOrThrow(userEmail);
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ResourceNotFoundException("Listing", listingId));

        if (!favoriteRepository.existsByUserIdAndListing(user.getId(), listing)) {
            throw new BusinessRuleException("Listing not in favorites");
        }

        favoriteRepository.deleteByUserIdAndListing(user.getId(), listing);
        log.debug("Favorite removed: {} -> {}", userEmail, listingId);
    }

    @Transactional(readOnly = true)
    public PageResponse<ListingDto> getFavorites(String userEmail, int page, int size) {
        UserView user = getUserOrThrow(userEmail);
        return PageResponse.from(
                favoriteRepository.findByUserIdOrderByCreatedAtDesc(user.getId(), PageRequest.of(page, size)),
                fav -> listingService.toListingDtoPublic(fav.getListing())
        );
    }

    private UserView getUserOrThrow(String email) {
        return userViewRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", email));
    }
}
