package com.automarket.inquiry.controller;

import com.automarket.common.dto.PageResponse;
import com.automarket.inquiry.dto.InquiryDto;
import com.automarket.inquiry.dto.SendInquiryRequest;
import com.automarket.inquiry.service.InquiryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/inquiries")
@RequiredArgsConstructor
public class InquiryController {

    private final InquiryService inquiryService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public InquiryDto send(@Valid @RequestBody SendInquiryRequest request) {
        return inquiryService.send(request, getCurrentUserEmail());
    }

    @GetMapping("/received")
    public PageResponse<InquiryDto> getReceived(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return inquiryService.getReceived(getCurrentUserEmail(), page, size);
    }

    @GetMapping("/sent")
    public PageResponse<InquiryDto> getSent(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return inquiryService.getSent(getCurrentUserEmail(), page, size);
    }

    @PutMapping("/{id}/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void markAsRead(@PathVariable UUID id) {
        inquiryService.markAsRead(id, getCurrentUserEmail());
    }

    private String getCurrentUserEmail() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication.getName();
    }
}
