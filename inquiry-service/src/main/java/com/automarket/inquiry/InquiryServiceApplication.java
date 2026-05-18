package com.automarket.inquiry;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = "com.automarket")
public class InquiryServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(InquiryServiceApplication.class, args);
    }
}
