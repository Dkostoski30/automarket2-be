package com.automarket.auth.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.test.util.ReflectionTestUtils;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.PublicKey;
import java.util.Date;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * RS256 token issuance, and — the part no compiler checks — that the gateway can
 * verify what auth-service signs.
 *
 * <p>The keys are read from the two services' real application.yml defaults rather
 * than generated here. The failure worth catching is a private key in auth-service
 * that does not pair with the public key in the gateway: everything compiles, both
 * services start, and every authenticated request then 401s at the edge.
 */
class JwtServiceTest {

    private static final Pattern PRIVATE = Pattern.compile("private-key: \\$\\{JWT_PRIVATE_KEY:([^}]+)}");
    private static final Pattern PUBLIC = Pattern.compile("public-key: \\$\\{JWT_PUBLIC_KEY:([^}]+)}");

    private JwtService jwtService;
    private final UserDetails user = new User("seller@automarket.com", "x", List.of());

    @BeforeEach
    void setUp() throws IOException {
        String authYaml = read("src/main/resources/application.yml");
        jwtService = new JwtService();
        ReflectionTestUtils.setField(jwtService, "privateKeyPem", extract(PRIVATE, authYaml));
        ReflectionTestUtils.setField(jwtService, "publicKeyPem", extract(PUBLIC, authYaml));
        ReflectionTestUtils.setField(jwtService, "accessTokenExpiryMs", 60_000L);
        jwtService.loadKeys();
    }

    @Test
    void issuesRs256TokensItCanVerify() {
        String token = jwtService.generateAccessToken(user);

        assertThat(token.split("\\.")[0]).isEqualTo(
                java.util.Base64.getUrlEncoder().withoutPadding()
                        .encodeToString("{\"alg\":\"RS256\"}".getBytes(StandardCharsets.UTF_8)));
        assertThat(jwtService.extractUsername(token)).isEqualTo("seller@automarket.com");
        assertThat(jwtService.isTokenValid(token, user)).isTrue();
    }

    @Test
    void gatewayPublicKeyVerifiesTokensAuthServiceSigns() throws IOException {
        String gatewayYaml = read("../gateway/src/main/resources/application.yml");
        PublicKey gatewayKey = RsaKeys.publicKey(extract(PUBLIC, gatewayYaml));

        String token = jwtService.generateAccessToken(user);

        Claims claims = Jwts.parser().verifyWith(gatewayKey).build()
                .parseSignedClaims(token).getPayload();
        assertThat(claims.getSubject()).isEqualTo("seller@automarket.com");
    }

    @Test
    void rejectsTokensSignedWithTheRetiredSharedSecret() {
        // The exact string every pod used to hold. A token minted with it must not
        // verify now, or rotating to RS256 bought nothing.
        String forged = Jwts.builder()
                .subject("attacker@automarket.com")
                .claim("roles", List.of("ROLE_ADMIN"))
                .expiration(new Date(System.currentTimeMillis() + 60_000))
                .signWith(Keys.hmacShaKeyFor(
                        "change-this-secret-in-production-must-be-at-least-32-chars"
                                .getBytes(StandardCharsets.UTF_8)))
                .compact();

        assertThatThrownBy(() -> jwtService.extractUsername(forged))
                .isInstanceOf(JwtException.class);
    }

    @Test
    void rejectsATamperedPayload() {
        String[] parts = jwtService.generateAccessToken(user).split("\\.");
        String forgedPayload = java.util.Base64.getUrlEncoder().withoutPadding().encodeToString(
                "{\"sub\":\"admin@automarket.com\"}".getBytes(StandardCharsets.UTF_8));
        String tampered = parts[0] + "." + forgedPayload + "." + parts[2];

        assertThatThrownBy(() -> jwtService.extractUsername(tampered))
                .isInstanceOf(JwtException.class);
    }

    @Test
    void acceptsArmouredMultiLinePem() {
        // secret.yml.example tells operators to paste openssl output verbatim, so
        // the armour lines and 64-column line breaks must be tolerated. A regex
        // that stripped only spaces would decode garbage here.
        String bare = (String) ReflectionTestUtils.getField(jwtService, "publicKeyPem");
        StringBuilder pem = new StringBuilder("-----BEGIN PUBLIC KEY-----\n");
        for (int i = 0; i < bare.length(); i += 64) {
            pem.append(bare, i, Math.min(i + 64, bare.length())).append("\r\n");
        }
        pem.append("-----END PUBLIC KEY-----\n");

        PublicKey key = RsaKeys.publicKey(pem.toString());

        Claims claims = Jwts.parser().verifyWith(key).build()
                .parseSignedClaims(jwtService.generateAccessToken(user)).getPayload();
        assertThat(claims.getSubject()).isEqualTo("seller@automarket.com");
    }

    @Test
    void failsFastOnAMissingKey() {
        JwtService unconfigured = new JwtService();
        ReflectionTestUtils.setField(unconfigured, "privateKeyPem", "");
        ReflectionTestUtils.setField(unconfigured, "publicKeyPem", "");

        assertThatThrownBy(unconfigured::loadKeys)
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("Missing RSA");
    }

    private static String read(String path) throws IOException {
        return Files.readString(Path.of(path));
    }

    private static String extract(Pattern pattern, String yaml) {
        Matcher m = pattern.matcher(yaml);
        assertThat(m.find()).as("pattern %s in application.yml", pattern).isTrue();
        return m.group(1);
    }
}
