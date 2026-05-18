package com.automarket.auth.dto;

public record TokenPair(
        String accessToken,
        String refreshToken,
        long accessTokenExpiresInMs
) {}
