package com.automarket.auth.service;

import com.automarket.auth.dto.UpdateProfileRequest;
import com.automarket.auth.dto.UserDto;
import com.automarket.auth.dto.UserProfileDto;
import com.automarket.auth.dto.UserSummaryDto;
import com.automarket.auth.entity.CityView;
import com.automarket.auth.entity.User;
import com.automarket.auth.repository.CityViewRepository;
import com.automarket.auth.repository.UserRepository;
import com.automarket.common.dto.PageResponse;
import com.automarket.auth.entity.Role;
import com.automarket.auth.repository.RoleRepository;
import com.automarket.common.exception.BusinessRuleException;
import com.automarket.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final CityViewRepository cityViewRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final EventPublisher eventPublisher;

    @Transactional(readOnly = true)
    public UserProfileDto getPublicProfile(UUID userId) {
        User user = getUserOrThrow(userId);
        // totalListings=0 placeholder; will be replaced with Feign call to listing-service
        return new UserProfileDto(user.getId(), user.getName(),
                user.getCity() != null ? user.getCity().getName() : null,
                user.getCreatedAt(), 0);
    }

    @Transactional(readOnly = true)
    public UserDto getMe(String email) {
        return toDto(getUserByEmailOrThrow(email));
    }

    @Transactional
    public UserDto updateProfile(String email, UpdateProfileRequest request) {
        User user = getUserByEmailOrThrow(email);

        if (request.name() != null) user.setName(request.name());
        if (request.phone() != null) user.setPhone(request.phone());
        if (request.cityId() != null) {
            CityView city = cityViewRepository.findById(request.cityId())
                    .orElseThrow(() -> new ResourceNotFoundException("City", request.cityId()));
            user.setCity(city);
        }
        return toDto(userRepository.save(user));
    }

    @Transactional
    public void changePassword(String email, String currentPassword, String newPassword) {
        User user = getUserByEmailOrThrow(email);
        if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
            throw new BusinessRuleException("Current password is incorrect");
        }
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        log.info("Password changed for user: {}", email);
    }

    @Transactional(readOnly = true)
    public PageResponse<UserDto> listAll(int page, int size) {
        return PageResponse.from(userRepository.findAllActive(PageRequest.of(page, size)), this::toDto);
    }

    @Transactional
    public UserDto updateRoles(UUID userId, Set<String> roleNames) {
        User user = getUserOrThrow(userId);
        Set<Role> roles = roleNames.stream()
                .map(name -> Role.RoleName.valueOf(name))
                .map(roleName -> roleRepository.findByName(roleName)
                        .orElseThrow(() -> new ResourceNotFoundException("Role", roleName.name())))
                .collect(Collectors.toSet());
        user.setRoles(roles);
        log.info("Roles updated for user {}: {}", userId, roleNames);
        return toDto(userRepository.save(user));
    }

    @Transactional
    public void deleteUser(UUID userId) {
        User user = getUserOrThrow(userId);
        user.setDeletedAt(Instant.now());
        userRepository.save(user);
        log.info("User soft-deleted: {}", userId);

        // Publish user.deleted event
        eventPublisher.publishUserDeleted(user.getId(), user.getEmail());
    }

    @Transactional(readOnly = true)
    public UserSummaryDto getUserSummary(UUID userId) {
        User user = getUserOrThrow(userId);
        return toSummaryDto(user);
    }

    @Transactional(readOnly = true)
    public UserSummaryDto getUserSummaryByEmail(String email) {
        User user = getUserByEmailOrThrow(email);
        return toSummaryDto(user);
    }

    private User getUserOrThrow(UUID id) {
        return userRepository.findById(id)
                .filter(u -> !u.isDeleted())
                .orElseThrow(() -> new ResourceNotFoundException("User", id));
    }

    private User getUserByEmailOrThrow(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", email));
    }

    private UserDto toDto(User u) {
        return new UserDto(
                u.getId(), u.getEmail(), u.getName(), u.getPhone(),
                u.getCity() != null ? u.getCity().getName() : null,
                u.getPlan(),
                u.getRoles().stream().map(r -> r.getName().name()).collect(Collectors.toSet()),
                u.getCreatedAt()
        );
    }

    private UserSummaryDto toSummaryDto(User u) {
        return new UserSummaryDto(
                u.getId(),
                u.getName(),
                u.getEmail(),
                u.getPhone(),
                u.getCity() != null ? u.getCity().getName() : null
        );
    }
}
