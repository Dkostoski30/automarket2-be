package com.automarket.inquiry.service;

import com.automarket.common.dto.PageResponse;
import com.automarket.common.exception.BusinessRuleException;
import com.automarket.common.exception.ResourceNotFoundException;
import com.automarket.inquiry.dto.InquiryDto;
import com.automarket.inquiry.dto.SendInquiryRequest;
import com.automarket.inquiry.entity.Inquiry;
import com.automarket.inquiry.entity.ListingView;
import com.automarket.inquiry.entity.UserView;
import com.automarket.inquiry.repository.InquiryRepository;
import com.automarket.inquiry.repository.ListingViewRepository;
import com.automarket.inquiry.repository.UserViewRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class InquiryService {

    private final InquiryRepository inquiryRepository;
    private final ListingViewRepository listingViewRepository;
    private final UserViewRepository userViewRepository;
    private final EventPublisher eventPublisher;

    @Transactional
    public InquiryDto send(SendInquiryRequest request, String senderEmail) {
        UserView sender = getUserOrThrow(senderEmail);
        ListingView listing = listingViewRepository.findById(request.listingId())
                .orElseThrow(() -> new ResourceNotFoundException("Listing", request.listingId()));

        if (!listing.isApproved()) {
            throw new BusinessRuleException("Cannot inquire about an unapproved listing");
        }

        UserView seller = userViewRepository.findById(listing.getSellerId())
                .orElseThrow(() -> new ResourceNotFoundException("User", listing.getSellerId()));

        if (seller.getEmail().equals(senderEmail)) {
            throw new BusinessRuleException("Cannot inquire about your own listing");
        }

        Inquiry inquiry = inquiryRepository.save(Inquiry.builder()
                .listingId(listing.getId())
                .senderId(sender.getId())
                .message(request.message())
                .build());

        eventPublisher.publishInquirySent(
                inquiry.getId(),
                listing.getId(),
                listing.getTitle(),
                sender.getId(),
                sender.getName(),
                sender.getEmail(),
                seller.getId(),
                seller.getEmail(),
                request.message());

        log.info("Inquiry sent: {} -> listing {}", senderEmail, listing.getId());
        return toDto(inquiry, listing.getTitle(), sender.getName());
    }

    @Transactional(readOnly = true)
    public PageResponse<InquiryDto> getReceived(String sellerEmail, int page, int size) {
        UserView seller = getUserOrThrow(sellerEmail);
        Page<Inquiry> inquiryPage = inquiryRepository.findReceivedBySeller(seller.getId(), PageRequest.of(page, size));
        return mapWithBatchLookup(inquiryPage);
    }

    @Transactional(readOnly = true)
    public PageResponse<InquiryDto> getSent(String senderEmail, int page, int size) {
        UserView sender = getUserOrThrow(senderEmail);
        Page<Inquiry> inquiryPage = inquiryRepository.findBySenderIdOrderByCreatedAtDesc(sender.getId(), PageRequest.of(page, size));
        return mapWithBatchLookup(inquiryPage);
    }

    private PageResponse<InquiryDto> mapWithBatchLookup(Page<Inquiry> inquiryPage) {
        Set<UUID> listingIds = inquiryPage.stream().map(Inquiry::getListingId).collect(Collectors.toSet());
        Set<UUID> senderIds = inquiryPage.stream().map(Inquiry::getSenderId).collect(Collectors.toSet());

        Map<UUID, String> listingTitles = listingViewRepository.findAllById(listingIds).stream()
                .collect(Collectors.toMap(ListingView::getId, ListingView::getTitle));
        Map<UUID, String> senderNames = userViewRepository.findAllById(senderIds).stream()
                .collect(Collectors.toMap(UserView::getId, UserView::getName));

        return PageResponse.from(inquiryPage, i -> toDto(i,
                listingTitles.getOrDefault(i.getListingId(), "Unknown Listing"),
                senderNames.getOrDefault(i.getSenderId(), "Unknown User")));
    }

    @Transactional
    public void markAsRead(UUID inquiryId, String sellerEmail) {
        Inquiry inquiry = inquiryRepository.findById(inquiryId)
                .orElseThrow(() -> new ResourceNotFoundException("Inquiry", inquiryId));

        ListingView listing = listingViewRepository.findById(inquiry.getListingId())
                .orElseThrow(() -> new ResourceNotFoundException("Listing", inquiry.getListingId()));

        UserView seller = getUserOrThrow(sellerEmail);
        if (!listing.getSellerId().equals(seller.getId())) {
            throw new BusinessRuleException("You are not the seller for this inquiry");
        }

        inquiry.setReadBySeller(true);
        inquiryRepository.save(inquiry);
    }

    private UserView getUserOrThrow(String email) {
        return userViewRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", email));
    }

    private InquiryDto toDto(Inquiry inquiry, String listingTitle, String senderName) {
        return new InquiryDto(
                inquiry.getId(),
                inquiry.getListingId(),
                listingTitle,
                inquiry.getSenderId(),
                senderName,
                inquiry.getMessage(),
                inquiry.isReadBySeller(),
                inquiry.getCreatedAt()
        );
    }
}
