package com.automarket.listing.service;

import com.automarket.listing.dto.ListingAnalyticsDto;
import com.automarket.listing.entity.Listing;
import com.automarket.listing.entity.ListingAnalytics;
import com.automarket.listing.repository.ListingAnalyticsRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final ListingAnalyticsRepository analyticsRepository;

    /**
     * Records one view of a listing.
     *
     * <p>Previously this recorded nothing at all. @Async was inert because no
     * @EnableAsync existed anywhere, so the method ran inline and joined the caller's
     * readOnly transaction; Hibernate set FlushMode.MANUAL, the write emitted no SQL,
     * and the catch block hid the fact. It was also called from a @Cacheable method,
     * so cache hits skipped it entirely.
     *
     * <p>Now: genuinely async (see AsyncConfig), REQUIRES_NEW so it can never inherit
     * a read-only transaction even if the async proxy is removed, and a single atomic
     * UPDATE rather than a read-modify-write.
     *
     * <p>Failures are logged and swallowed on purpose: view telemetry must never fail
     * a page load. This is unlike the notification consumer, where swallowing meant
     * losing a user-visible email.
     */
    @Async
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordView(UUID listingId) {
        try {
            analyticsRepository.incrementViewCount(listingId, LocalDate.now());
        } catch (Exception e) {
            log.warn("Failed to record view for listing {}: {}", listingId, e.getMessage());
        }
    }

    @Transactional(readOnly = true)
    public ListingAnalyticsDto getAnalytics(UUID listingId, Listing listing) {
        List<ListingAnalytics> records = analyticsRepository.findByListingOrderByDateDesc(listing);

        long totalViews = records.stream().mapToLong(ListingAnalytics::getViewCount).sum();
        long totalInquiries = records.stream().mapToLong(ListingAnalytics::getInquiryCount).sum();
        long totalFavorites = records.stream().mapToLong(ListingAnalytics::getFavoriteCount).sum();

        List<ListingAnalyticsDto.DailyStats> daily = records.stream()
                .limit(30)
                .map(r -> new ListingAnalyticsDto.DailyStats(
                        r.getDate(), r.getViewCount(), r.getInquiryCount(), r.getFavoriteCount()))
                .toList();

        return new ListingAnalyticsDto(listingId, totalViews, totalInquiries, totalFavorites, daily);
    }
}
