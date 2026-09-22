package com.automarket.listing.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

/**
 * Filter criteria for browsing listings. All fields are optional.
 * Handled by {@link com.automarket.listing.specification.ListingSpecification}.
 *
 * <p>{@code sellerId} is what a public seller profile lists that seller's cars with.
 * Browse is already public at the gateway and already restricted to approved,
 * non-deleted listings, so one predicate here beats a second endpoint: pagination,
 * sorting and every other filter come for free.
 */
public record ListingFilterRequest(
        String search,
        BigDecimal priceFrom,
        BigDecimal priceTo,
        Integer yearFrom,
        Integer yearTo,
        Integer kilometersFrom,
        Integer kilometersTo,
        Integer kilowattsFrom,
        Integer kilowattsTo,
        List<UUID> fuelTypeIds,
        List<UUID> bodyTypeIds,
        List<UUID> conditionTypeIds,
        List<UUID> transmissionTypeIds,
        List<UUID> brandIds,
        UUID cityId,
        UUID sellerId,   // one seller's cars — the public profile page
        Boolean featured,
        String sortBy,       // price, year, createdAt
        String sortDir       // asc, desc
) {}
