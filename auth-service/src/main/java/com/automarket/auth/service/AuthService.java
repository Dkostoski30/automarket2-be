package com.automarket.auth.service;

import com.automarket.auth.dto.RegisterRequest;
import com.automarket.auth.dto.TokenPair;
import com.automarket.auth.entity.CityView;
import com.automarket.auth.entity.RefreshToken;
import com.automarket.auth.entity.Role;
import com.automarket.auth.entity.User;
import com.automarket.auth.repository.CityViewRepository;
import com.automarket.auth.repository.RoleRepository;
import com.automarket.auth.repository.UserRepository;
import com.automarket.auth.security.JwtService;
import com.automarket.common.exception.BusinessRuleException;
import com.automarket.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final CityViewRepository cityViewRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;
    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;
    private final EventPublisher eventPublisher;

    @Transactional
    public TokenPair register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new BusinessRuleException("Email already registered: " + request.email());
        }

        CityView city = null;
        if (request.cityId() != null && !request.cityId().isBlank()) {
            city = cityViewRepository.findById(UUID.fromString(request.cityId()))
                    .orElseThrow(() -> new ResourceNotFoundException("City", request.cityId()));
        }

        User user = User.builder()
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .name(request.name())
                .phone(request.phone())
                .city(city)
                .build();

        // Assign default ROLE_USER
        roleRepository.findByName(Role.RoleName.ROLE_USER)
                .ifPresent(role -> user.getRoles().add(role));

        userRepository.save(user);
        log.info("New user registered: {}", request.email());

        // Publish user.registered event
        eventPublisher.publishUserRegistered(user);

        return buildTokenPair(user);
    }

    @Transactional
    public TokenPair login(String email, String password) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(email, password)
        );

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", email));

        refreshTokenService.revokeAllUserTokens(user);
        log.info("User logged in: {}", email);

        return buildTokenPair(user);
    }

    @Transactional
    public TokenPair refresh(String refreshTokenValue) {
        RefreshToken newRefreshToken = refreshTokenService.validateAndRotate(refreshTokenValue);
        User user = newRefreshToken.getUser();

        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
        String accessToken = jwtService.generateAccessToken(userDetails, buildRoleClaims(user));

        return new TokenPair(accessToken, newRefreshToken.getToken(), jwtService.getAccessTokenExpiryMs());
    }

    @Transactional
    public void logout(String email) {
        userRepository.findByEmail(email).ifPresent(refreshTokenService::revokeAllUserTokens);
        log.info("User logged out: {}", email);
    }

    private TokenPair buildTokenPair(User user) {
        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
        String accessToken = jwtService.generateAccessToken(userDetails, buildRoleClaims(user));
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(user);
        return new TokenPair(accessToken, refreshToken.getToken(), jwtService.getAccessTokenExpiryMs());
    }

    private Map<String, Object> buildRoleClaims(User user) {
        Set<String> roles = user.getRoles().stream()
                .map(r -> r.getName().name())
                .collect(Collectors.toSet());
        return Map.of("roles", roles, "plan", user.getPlan().name());
    }
}
