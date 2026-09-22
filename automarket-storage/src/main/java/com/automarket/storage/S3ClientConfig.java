package com.automarket.storage;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.S3ClientBuilder;

import java.net.URI;

/**
 * Configures the S3Client for the {@code s3} storage provider.
 *
 * <p>The client is endpoint-configurable rather than hardwired to AWS, because the
 * point of moving off local disk was to make listing-service and blog-service
 * stateless — and that must hold in a k3d cluster with no AWS account. With
 * {@code automarket.storage.s3.endpoint} set it talks to MinIO; left blank it
 * resolves the real AWS endpoint for the configured region, unchanged from before.
 *
 * <p>Path-style access ({@code bucket} in the path rather than the hostname) is
 * required for MinIO, since {@code bucket.minio} does not resolve in-cluster. AWS
 * has deprecated it, hence the separate flag rather than tying it to the endpoint.
 *
 * <p>Credentials fall back to the SDK default chain (environment, instance profile)
 * when no static key is configured, so an AWS deployment needs no property changes.
 */
@Slf4j
@Configuration
@ConditionalOnProperty(name = "automarket.storage.provider", havingValue = "s3")
public class S3ClientConfig {

    @Value("${automarket.storage.s3.region:eu-central-1}")
    private String region;

    @Value("${automarket.storage.s3.endpoint:}")
    private String endpoint;

    @Value("${automarket.storage.s3.path-style:false}")
    private boolean pathStyle;

    @Value("${automarket.storage.s3.access-key:}")
    private String accessKey;

    @Value("${automarket.storage.s3.secret-key:}")
    private String secretKey;

    @Bean
    public S3Client s3Client() {
        S3ClientBuilder builder = S3Client.builder().region(Region.of(region));

        if (!endpoint.isBlank()) {
            builder.endpointOverride(URI.create(endpoint));
            log.info("S3 storage using endpoint override {} (path-style={})", endpoint, pathStyle);
        }
        if (pathStyle) {
            builder.forcePathStyle(true);
        }
        if (!accessKey.isBlank() && !secretKey.isBlank()) {
            builder.credentialsProvider(StaticCredentialsProvider.create(
                    AwsBasicCredentials.create(accessKey, secretKey)));
        }

        return builder.build();
    }
}
