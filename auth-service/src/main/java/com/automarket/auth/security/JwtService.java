package com.automarket.auth.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.time.Instant;
import java.util.Date;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;

/**
 * Issues and verifies access tokens.
 *
 * <p>Signing is RS256, not HS256. Under the previous symmetric scheme the signing
 * key lived in the shared automarket-secret that every deployment mounted, so
 * blog-service and notification-service — neither of which touches a token — held
 * the key that mints ROLE_ADMIN tokens. One compromised pod was total compromise.
 * Now auth-service is the only holder of the private key; the gateway verifies
 * with the public half, which is not a secret at all and ships in the ConfigMap.
 */
@Slf4j
@Service
public class JwtService {

    @Value("${automarket.jwt.private-key}")
    private String privateKeyPem;

    @Value("${automarket.jwt.public-key}")
    private String publicKeyPem;

    @Value("${automarket.jwt.access-token-expiry-ms}")
    private long accessTokenExpiryMs;

    private PrivateKey signingKey;
    private PublicKey verificationKey;

    /**
     * Parsed once at startup rather than per token: fail fast on a malformed key,
     * and do not pay KeyFactory costs on every login.
     */
    @PostConstruct
    void loadKeys() {
        this.signingKey = RsaKeys.privateKey(privateKeyPem);
        this.verificationKey = RsaKeys.publicKey(publicKeyPem);
        log.info("JWT signing initialised with RS256");
    }

    public String generateAccessToken(UserDetails userDetails, Map<String, Object> extraClaims) {
        return buildToken(userDetails.getUsername(), extraClaims, accessTokenExpiryMs);
    }

    public String generateAccessToken(UserDetails userDetails) {
        return generateAccessToken(userDetails, Map.of());
    }

    private String buildToken(String subject, Map<String, Object> claims, long expiryMs) {
        Instant now = Instant.now();
        return Jwts.builder()
                .claims(claims)
                .subject(subject)
                .id(UUID.randomUUID().toString())
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusMillis(expiryMs)))
                .signWith(signingKey)
                .compact();
    }

    public boolean isTokenValid(String token, UserDetails userDetails) {
        try {
            String username = extractUsername(token);
            return username.equals(userDetails.getUsername()) && !isTokenExpired(token);
        } catch (JwtException | IllegalArgumentException e) {
            log.warn("Invalid JWT token: {}", e.getMessage());
            return false;
        }
    }

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(verificationKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public long getAccessTokenExpiryMs() {
        return accessTokenExpiryMs;
    }
}
