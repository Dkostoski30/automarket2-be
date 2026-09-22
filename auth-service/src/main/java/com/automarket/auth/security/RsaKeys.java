package com.automarket.auth.security;

import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

/**
 * Parses PEM-encoded RSA keys supplied as configuration.
 *
 * <p>Deliberately duplicated in the gateway rather than shared: the obvious home
 * would be automarket-common, but that pulls spring-boot-starter-web, and Spring
 * MVC on the classpath stops Spring Cloud Gateway from starting. The same
 * reasoning already forces JwtValidationFilter to re-declare the header names.
 *
 * <p>Keys arrive as PEM because that is what a Kubernetes Secret and an .env file
 * can both carry as text. Newlines inside the value are optional — some secret
 * stores strip them — so everything between the armour lines is treated as one
 * Base64 blob.
 */
final class RsaKeys {

    private RsaKeys() {
    }

    static PrivateKey privateKey(String pem) {
        return parse(pem, "PRIVATE KEY", bytes -> {
            try {
                return KeyFactory.getInstance("RSA").generatePrivate(new PKCS8EncodedKeySpec(bytes));
            } catch (Exception e) {
                throw new IllegalStateException("automarket.jwt.private-key is not a valid PKCS#8 RSA key", e);
            }
        });
    }

    static PublicKey publicKey(String pem) {
        return parse(pem, "PUBLIC KEY", bytes -> {
            try {
                return KeyFactory.getInstance("RSA").generatePublic(new X509EncodedKeySpec(bytes));
            } catch (Exception e) {
                throw new IllegalStateException("automarket.jwt.public-key is not a valid X.509 RSA key", e);
            }
        });
    }

    private static <T> T parse(String pem, String label, java.util.function.Function<byte[], T> decoder) {
        if (pem == null || pem.isBlank()) {
            throw new IllegalStateException("Missing RSA " + label.toLowerCase()
                    + ". Generate a keypair with the commands in docs/devops.md.");
        }
        String base64 = pem
                .replace("-----BEGIN " + label + "-----", "")
                .replace("-----END " + label + "-----", "")
                .replaceAll("\\s", "");
        return decoder.apply(Base64.getDecoder().decode(base64));
    }
}
