package com.automarket.service;

import com.automarket.dto.admin.AdminUserDto;
import com.automarket.dto.shared.PageResponse;
import com.automarket.entity.Role;
import com.automarket.entity.Role.RoleName;
import com.automarket.entity.User;
import com.automarket.exception.BusinessRuleException;
import com.automarket.exception.ResourceNotFoundException;
import com.automarket.repository.ListingRepository;
import com.automarket.repository.RoleRepository;
import com.automarket.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AdminUserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ListingRepository listingRepository;
    private final RefreshTokenService refreshTokenService;

    @Transactional(readOnly = true)
    public PageResponse<AdminUserDto> listUsers(int page, int size, String search) {
        int safeSize = Math.min(size, 50);
        PageRequest pageRequest = PageRequest.of(page, safeSize, Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<User> users;
        if (search != null && !search.isBlank()) {
            users = userRepository.searchActive(search.trim(), pageRequest);
        } else {
            users = userRepository.findAllActive(pageRequest);
        }

        return PageResponse.from(users, this::toAdminDto);
    }

    @Transactional(readOnly = true)
    public AdminUserDto getUserById(UUID id) {
        User user = getActiveUserOrThrow(id);
        return toAdminDto(user);
    }

    @Transactional
    public AdminUserDto updateRoles(UUID targetUserId, Set<String> roleNames, String callerEmail) {
        User caller = userRepository.findByEmail(callerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User", callerEmail));
        User target = getActiveUserOrThrow(targetUserId);

        // Cannot change own roles
        if (caller.getId().equals(target.getId())) {
            throw new BusinessRuleException("Cannot modify your own roles");
        }

        // ROLE_USER must always be present
        if (!roleNames.contains("ROLE_USER")) {
            throw new BusinessRuleException("ROLE_USER must always be present");
        }

        boolean callerIsSuperAdmin = hasRole(caller, RoleName.ROLE_SUPERADMIN);
        boolean targetIsSuperAdmin = hasRole(target, RoleName.ROLE_SUPERADMIN);

        // ADMIN cannot modify SUPERADMIN users
        if (!callerIsSuperAdmin && targetIsSuperAdmin) {
            throw new BusinessRuleException("Cannot modify a SUPERADMIN user's roles");
        }

        // Only SUPERADMIN can assign/revoke ADMIN or SUPERADMIN
        if (!callerIsSuperAdmin) {
            if (roleNames.contains("ROLE_ADMIN") && !hasRole(target, RoleName.ROLE_ADMIN)) {
                throw new BusinessRuleException("Only SUPERADMIN can assign ADMIN role");
            }
            if (roleNames.contains("ROLE_SUPERADMIN")) {
                throw new BusinessRuleException("Only SUPERADMIN can assign SUPERADMIN role");
            }
            // ADMIN removing ADMIN role from another ADMIN
            if (!roleNames.contains("ROLE_ADMIN") && hasRole(target, RoleName.ROLE_ADMIN)) {
                throw new BusinessRuleException("Only SUPERADMIN can revoke ADMIN role");
            }
        }

        Set<Role> newRoles = roleNames.stream()
                .map(name -> {
                    RoleName roleName = RoleName.valueOf(name);
                    return roleRepository.findByName(roleName)
                            .orElseThrow(() -> new ResourceNotFoundException("Role", name));
                })
                .collect(Collectors.toSet());

        target.setRoles(newRoles);
        userRepository.save(target);
        log.info("Roles updated for user {} by {}: {}", targetUserId, callerEmail, roleNames);
        return toAdminDto(target);
    }

    @Transactional
    public AdminUserDto updateStatus(UUID targetUserId, boolean enabled, String callerEmail) {
        User caller = userRepository.findByEmail(callerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User", callerEmail));
        User target = getActiveUserOrThrow(targetUserId);

        // Cannot disable own account
        if (caller.getId().equals(target.getId())) {
            throw new BusinessRuleException("Cannot change your own account status");
        }

        boolean callerIsSuperAdmin = hasRole(caller, RoleName.ROLE_SUPERADMIN);

        // ADMIN cannot disable SUPERADMIN
        if (!callerIsSuperAdmin && hasRole(target, RoleName.ROLE_SUPERADMIN)) {
            throw new BusinessRuleException("Cannot disable a SUPERADMIN user");
        }

        // ADMIN cannot disable another ADMIN
        if (!callerIsSuperAdmin && hasRole(target, RoleName.ROLE_ADMIN)) {
            throw new BusinessRuleException("Only SUPERADMIN can disable an ADMIN user");
        }

        target.setEnabled(enabled);
        userRepository.save(target);

        // Invalidate tokens when disabling
        if (!enabled) {
            refreshTokenService.revokeAllUserTokens(target);
            log.info("User {} disabled by {}, tokens revoked", targetUserId, callerEmail);
        } else {
            log.info("User {} enabled by {}", targetUserId, callerEmail);
        }

        return toAdminDto(target);
    }

    @Transactional
    public void deleteUser(UUID targetUserId, String callerEmail) {
        User caller = userRepository.findByEmail(callerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User", callerEmail));
        User target = getActiveUserOrThrow(targetUserId);

        // Cannot delete self
        if (caller.getId().equals(target.getId())) {
            throw new BusinessRuleException("Cannot delete your own account");
        }

        // Revoke tokens before deletion
        refreshTokenService.revokeAllUserTokens(target);

        // DB cascade handles listings, favorites, inquiries, etc.
        userRepository.delete(target);
        log.info("User {} permanently deleted by {}", targetUserId, callerEmail);
    }

    private User getActiveUserOrThrow(UUID id) {
        return userRepository.findById(id)
                .filter(u -> !u.isDeleted())
                .orElseThrow(() -> new ResourceNotFoundException("User", id));
    }

    private boolean hasRole(User user, RoleName roleName) {
        return user.getRoles().stream().anyMatch(r -> r.getName() == roleName);
    }

    private AdminUserDto toAdminDto(User u) {
        List<String> roles = u.getRoles().stream()
                .map(r -> r.getName().name())
                .sorted()
                .collect(Collectors.toList());

        return new AdminUserDto(
                u.getId(),
                u.getEmail(),
                u.getName(),
                u.getPhone(),
                u.getCity() != null ? u.getCity().getName() : null,
                u.getPlan().name(),
                roles,
                u.getCreatedAt(),
                listingRepository.countTotalByUserId(u.getId()),
                listingRepository.countActiveByUserId(u.getId()),
                u.isEnabled()
        );
    }
}
