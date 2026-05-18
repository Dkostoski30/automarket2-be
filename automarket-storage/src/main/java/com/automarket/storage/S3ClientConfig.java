package com.automarket.storage;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;

/**
 * Configures the AWS S3Client when using the S3 storage provider.
 * AWS credentials are read from the environment (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
 * or EC2 instance profile automatically by the AWS SDK default credentials chain.
 */
@Configuration
@ConditionalOnProperty(name = "automarket.storage.provider", havingValue = "s3")
public class S3ClientConfig {

    @Bean
    public S3Client s3Client() {
        return S3Client.builder()
                .region(Region.EU_CENTRAL_1)
                .build();
    }
}
