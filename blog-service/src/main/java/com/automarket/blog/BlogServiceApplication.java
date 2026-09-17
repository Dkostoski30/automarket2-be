package com.automarket.blog;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication(scanBasePackages = "com.automarket")
@EnableJpaAuditing
public class BlogServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(BlogServiceApplication.class, args);
    }
}
