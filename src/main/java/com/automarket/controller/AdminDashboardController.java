package com.automarket.controller;

import com.automarket.repository.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/dashboard")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasAnyRole('MODERATOR', 'ADMIN', 'SUPERADMIN')")
@Tag(name = "Admin - Dashboard")
public class AdminDashboardController {

    private final ListingRepository listingRepository;
    private final UserRepository userRepository;
    private final CarBrandRepository carBrandRepository;
    private final BlogRepository blogRepository;

    @GetMapping
    @Operation(summary = "Get admin dashboard statistics")
    public Map<String, Object> getDashboard() {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("pendingListings", listingRepository.countPendingApproval());
        stats.put("approvedListings", listingRepository.countApproved());
        stats.put("totalUsers", userRepository.count());
        stats.put("activeUsers", userRepository.countActiveUsers());
        stats.put("disabledUsers", userRepository.countDisabledUsers());
        stats.put("totalBrands", carBrandRepository.count());
        stats.put("totalBlogs", blogRepository.count());
        return stats;
    }
}
