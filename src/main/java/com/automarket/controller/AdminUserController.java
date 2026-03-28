package com.automarket.controller;

import com.automarket.dto.admin.AdminUserDto;
import com.automarket.dto.admin.UpdateRolesRequest;
import com.automarket.dto.admin.UpdateStatusRequest;
import com.automarket.dto.shared.PageResponse;
import com.automarket.service.AdminUserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin/users")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")
@Tag(name = "Admin - Users")
public class AdminUserController {

    private final AdminUserService adminUserService;

    @GetMapping
    @Operation(summary = "List all users (paginated, with optional search)")
    public PageResponse<AdminUserDto> listAll(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String search) {
        return adminUserService.listUsers(page, size, search);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a single user's admin detail")
    public AdminUserDto getById(@PathVariable UUID id) {
        return adminUserService.getUserById(id);
    }

    @PutMapping("/{id}/roles")
    @Operation(summary = "Update a user's roles")
    public AdminUserDto updateRoles(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateRolesRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        return adminUserService.updateRoles(id, request.roles(), userDetails.getUsername());
    }

    @PutMapping("/{id}/status")
    @Operation(summary = "Enable or disable a user account")
    public AdminUserDto updateStatus(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateStatusRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        return adminUserService.updateStatus(id, request.enabled(), userDetails.getUsername());
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('SUPERADMIN')")
    @Operation(summary = "Permanently delete a user account")
    public void deleteUser(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserDetails userDetails) {
        adminUserService.deleteUser(id, userDetails.getUsername());
    }
}
