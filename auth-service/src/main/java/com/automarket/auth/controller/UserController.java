package com.automarket.auth.controller;

import com.automarket.auth.dto.ChangePasswordRequest;
import com.automarket.auth.dto.UpdateProfileRequest;
import com.automarket.auth.dto.UserDto;
import com.automarket.auth.dto.UserProfileDto;
import com.automarket.auth.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "Users")
public class UserController {

    private final UserService userService;

    @GetMapping("/{id}")
    @Operation(summary = "Get a user's public profile")
    public UserProfileDto getPublicProfile(@PathVariable UUID id) {
        return userService.getPublicProfile(id);
    }

    @GetMapping("/me")
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Get current user's full profile")
    public UserDto getMe(@AuthenticationPrincipal String email) {
        return userService.getMe(email);
    }

    @PutMapping("/me")
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Update current user's profile")
    public UserDto updateMe(@Valid @RequestBody UpdateProfileRequest request,
                            @AuthenticationPrincipal String email) {
        return userService.updateProfile(email, request);
    }

    @PutMapping("/me/password")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Change current user's password")
    public void changePassword(@Valid @RequestBody ChangePasswordRequest request,
                               @AuthenticationPrincipal String email) {
        userService.changePassword(email, request.currentPassword(), request.newPassword());
    }
}
