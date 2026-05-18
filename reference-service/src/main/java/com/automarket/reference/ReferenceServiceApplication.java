package com.automarket.reference;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = "com.automarket")
public class ReferenceServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(ReferenceServiceApplication.class, args);
    }
}
