package com.automarket.blog.controller;

import com.automarket.blog.dto.BlogDto;
import com.automarket.blog.dto.BlogRequest;
import com.automarket.blog.service.BlogService;
import com.automarket.common.dto.PageResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/blog")
@RequiredArgsConstructor
@Tag(name = "Blog")
public class BlogController {

    private final BlogService blogService;

    @GetMapping
    @Operation(summary = "List blog posts (paginated)")
    public PageResponse<BlogDto> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "6") int size) {
        return blogService.list(page, size);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a blog post by ID")
    public BlogDto getById(@PathVariable UUID id) {
        return blogService.getById(id);
    }

    @GetMapping("/slug/{slug}")
    @Operation(summary = "Get a blog post by slug")
    public BlogDto getBySlug(@PathVariable String slug) {
        return blogService.getBySlug(slug);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasAnyRole('MODERATOR', 'ADMIN')")
    @Operation(summary = "Create a blog post")
    public BlogDto create(@Valid @RequestBody BlogRequest request,
                          @AuthenticationPrincipal String email) {
        return blogService.create(request, email);
    }

    @PutMapping("/{id}")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasAnyRole('MODERATOR', 'ADMIN')")
    @Operation(summary = "Update a blog post")
    public BlogDto update(@PathVariable UUID id, @Valid @RequestBody BlogRequest request) {
        return blogService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a blog post")
    public void delete(@PathVariable UUID id) {
        blogService.delete(id);
    }

    @PostMapping("/{id}/cover-image")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasAnyRole('MODERATOR', 'ADMIN')")
    @Operation(summary = "Upload a cover image for a blog post")
    public ResponseEntity<BlogDto> uploadCoverImage(
            @PathVariable UUID id,
            @RequestParam("file") MultipartFile file) {
        return ResponseEntity.ok(blogService.uploadCoverImage(id, file));
    }

    @PostMapping("/images")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasAnyRole('MODERATOR', 'ADMIN')")
    @Operation(summary = "Upload an inline content image for blog posts")
    public ResponseEntity<Map<String, String>> uploadContentImage(
            @RequestParam("file") MultipartFile file) {
        return ResponseEntity.ok(Map.of("url", blogService.uploadContentImage(file)));
    }
}
