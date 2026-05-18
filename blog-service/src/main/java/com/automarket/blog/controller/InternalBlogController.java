package com.automarket.blog.controller;

import com.automarket.blog.service.BlogService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * Internal API — not exposed via the API Gateway.
 * Called by listing-service/admin dashboard for aggregate stats.
 */
@RestController
@RequestMapping("/internal/blogs")
@RequiredArgsConstructor
public class InternalBlogController {

    private final BlogService blogService;

    /**
     * Returns total blog post count for admin dashboard.
     */
    @GetMapping("/count")
    public Map<String, Long> getBlogCount() {
        return Map.of("count", blogService.getBlogCount());
    }
}
