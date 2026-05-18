package com.automarket.auth.controller;

import com.automarket.auth.dto.UserSummaryDto;
import com.automarket.auth.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * Internal API for service-to-service communication.
 * Not exposed through the gateway — only accessible within the internal network.
 */
@RestController
@RequestMapping("/internal/users")
@RequiredArgsConstructor
public class InternalUserController {

    private final UserService userService;

    @GetMapping("/{id}")
    public UserSummaryDto getUser(@PathVariable UUID id) {
        return userService.getUserSummary(id);
    }

    @GetMapping("/by-email/{email}")
    public UserSummaryDto getUserByEmail(@PathVariable String email) {
        return userService.getUserSummaryByEmail(email);
    }
}
