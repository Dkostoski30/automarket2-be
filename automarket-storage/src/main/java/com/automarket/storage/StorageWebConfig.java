package com.automarket.storage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Paths;

/**
 * Serves locally stored upload files at /uploads/** when using local storage provider.
 * In production (S3), this is inactive — files are served via CloudFront CDN.
 */
@Configuration
@ConditionalOnProperty(name = "automarket.storage.provider", havingValue = "local", matchIfMissing = true)
public class StorageWebConfig implements WebMvcConfigurer {

    @Value("${automarket.storage.local.upload-dir:./uploads}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String absolutePath = Paths.get(uploadDir).toAbsolutePath().normalize().toUri().toString();
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations(absolutePath);
    }
}
