package com.automarket.listing.controller;

import com.automarket.listing.dto.*;
import com.automarket.listing.entity.Listing;
import com.automarket.listing.repository.ListingRepository;
import com.automarket.listing.service.AnalyticsService;
import com.automarket.listing.service.FavoriteService;
import com.automarket.listing.service.ListingService;
import com.automarket.common.dto.PageResponse;
import com.automarket.common.exception.ResourceNotFoundException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/listings")
@RequiredArgsConstructor
@Tag(name = "Listings")
public class ListingController {

    private final ListingService listingService;
    private final FavoriteService favoriteService;
    private final AnalyticsService analyticsService;
    private final ListingRepository listingRepository;

    @GetMapping
    @Operation(summary = "Browse listings with filters and pagination")
    public PageResponse<ListingDto> browse(
            ListingFilterRequest filter,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size) {
        return listingService.browse(filter, page, size);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get listing details by ID")
    public ListingDetailDto getById(@PathVariable UUID id) {
        ListingDetailDto listing = listingService.getById(id);
        // Deliberately here and not inside getById: that method is @Cacheable, so on a
        // cache hit its body never runs and the view would go uncounted.
        analyticsService.recordView(listing.id());
        return listing;
    }

    @GetMapping("/slug/{slug}")
    @Operation(summary = "Get listing details by SEO slug")
    public ListingDetailDto getBySlug(@PathVariable String slug) {
        ListingDetailDto listing = listingService.getBySlug(slug);
        analyticsService.recordView(listing.id());
        return listing;
    }

    @GetMapping("/featured")
    @Operation(summary = "Get active featured listings")
    public List<ListingDto> getFeatured() {
        return listingService.getFeatured();
    }

    @GetMapping("/my")
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Get current user's own listings")
    public PageResponse<ListingDto> getMyListings(
            @AuthenticationPrincipal String email,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return listingService.getMyListings(email, page, size);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Create a new listing")
    public ListingDetailDto create(
            @Valid @RequestBody CreateListingRequest request,
            @AuthenticationPrincipal String email) {
        return listingService.create(request, email);
    }

    @PutMapping("/{id}")
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Update an existing listing (owner or admin only)")
    public ListingDetailDto update(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateListingRequest request,
            @AuthenticationPrincipal String email) {
        return listingService.update(id, request, email);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Delete a listing (owner or admin only)")
    public void delete(
            @PathVariable UUID id,
            @AuthenticationPrincipal String email) {
        listingService.delete(id, email);
    }

    @PostMapping(value = "/{id}/images", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Upload images to a listing (max 10)")
    public ListingDetailDto addImage(
            @PathVariable UUID id,
            @RequestPart("file") MultipartFile file,
            @AuthenticationPrincipal String email) {
        return listingService.addImage(id, file, email);
    }

    @DeleteMapping("/{listingId}/images/{imageId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Delete an image from a listing")
    public void deleteImage(
            @PathVariable UUID listingId,
            @PathVariable UUID imageId,
            @AuthenticationPrincipal String email) {
        listingService.deleteImage(listingId, imageId, email);
    }

    @PostMapping("/{id}/favorite")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Add listing to favorites")
    public void favorite(
            @PathVariable UUID id,
            @AuthenticationPrincipal String email) {
        favoriteService.add(id, email);
    }

    @DeleteMapping("/{id}/favorite")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Remove listing from favorites")
    public void unfavorite(
            @PathVariable UUID id,
            @AuthenticationPrincipal String email) {
        favoriteService.remove(id, email);
    }

    @GetMapping("/{id}/analytics")
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Get analytics for a listing (owner or admin only)")
    public ListingAnalyticsDto getAnalytics(@PathVariable UUID id) {
        Listing listing = listingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Listing", id));
        return analyticsService.getAnalytics(id, listing);
    }
}
