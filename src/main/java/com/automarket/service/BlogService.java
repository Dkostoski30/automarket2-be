package com.automarket.service;

import com.automarket.dto.blog.BlogAuthorDto;
import com.automarket.dto.blog.BlogDto;
import com.automarket.dto.blog.BlogRequest;
import com.automarket.dto.shared.PageResponse;
import com.automarket.entity.Blog;
import com.automarket.entity.User;
import com.automarket.exception.ResourceNotFoundException;
import com.automarket.repository.BlogRepository;
import com.automarket.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.text.Normalizer;
import java.util.Locale;
import java.util.UUID;
import java.util.regex.Pattern;

@Slf4j
@Service
@RequiredArgsConstructor
public class BlogService {

    private final BlogRepository blogRepository;
    private final UserRepository userRepository;
    private final StorageService storageService;

    private static final Pattern NON_LATIN = Pattern.compile("[^\\w-]");
    private static final Pattern WHITESPACE = Pattern.compile("[\\s]+");

    @Transactional(readOnly = true)
    public PageResponse<BlogDto> list(int page, int size) {
        return PageResponse.from(
                blogRepository.findAllOrderByCreatedAtDesc(PageRequest.of(page, size)),
                this::toDto
        );
    }

    @Transactional(readOnly = true)
    public BlogDto getById(UUID id) {
        return toDto(blogRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Blog", id)));
    }

    @Transactional(readOnly = true)
    public BlogDto getBySlug(String slug) {
        return toDto(blogRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Blog", slug)));
    }

    @Transactional
    public BlogDto create(BlogRequest request, String authorEmail) {
        User author = userRepository.findByEmail(authorEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User", authorEmail));

        Blog blog = Blog.builder()
                .title(request.title())
                .slug(generateUniqueSlug(request.title()))
                .excerpt(request.excerpt())
                .content(request.content())
                .coverImageUrl(request.coverImageUrl())
                .published(request.published() != null ? request.published() : false)
                .author(author)
                .build();

        blogRepository.save(blog);
        log.info("Blog created: {} by {}", blog.getId(), authorEmail);
        return toDto(blog);
    }

    @Transactional
    public BlogDto update(UUID id, BlogRequest request) {
        Blog blog = blogRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Blog", id));

        blog.setTitle(request.title());
        blog.setSlug(generateUniqueSlug(request.title(), blog.getSlug()));
        blog.setExcerpt(request.excerpt());
        blog.setContent(request.content());
        if (request.coverImageUrl() != null) {
            blog.setCoverImageUrl(request.coverImageUrl());
        }
        if (request.published() != null) {
            blog.setPublished(request.published());
        }
        return toDto(blogRepository.save(blog));
    }

    @Transactional
    public void delete(UUID id) {
        Blog blog = blogRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Blog", id));

        if (blog.getCoverImageKey() != null) {
            storageService.delete(blog.getCoverImageKey());
        }

        blogRepository.delete(blog);
        log.info("Blog deleted: {}", id);
    }

    @Transactional
    public BlogDto uploadCoverImage(UUID id, MultipartFile file) {
        Blog blog = blogRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Blog", id));

        if (blog.getCoverImageKey() != null) {
            storageService.delete(blog.getCoverImageKey());
        }

        StorageService.UploadResult result = storageService.store(file, "blog/covers/" + id);
        blog.setCoverImageUrl(result.url());
        blog.setCoverImageKey(result.storageKey());

        return toDto(blogRepository.save(blog));
    }

    public String uploadContentImage(MultipartFile file) {
        StorageService.UploadResult result = storageService.store(file, "blog/content");
        return result.url();
    }

    private BlogDto toDto(Blog b) {
        BlogAuthorDto authorDto = b.getAuthor() != null
                ? new BlogAuthorDto(b.getAuthor().getId(), b.getAuthor().getName())
                : null;

        return new BlogDto(
                b.getId(),
                b.getTitle(),
                b.getSlug(),
                b.getExcerpt(),
                b.getContent(),
                b.getCoverImageUrl(),
                authorDto,
                b.getPublished(),
                b.getCreatedAt(),
                b.getUpdatedAt()
        );
    }

    private String generateUniqueSlug(String title) {
        return generateUniqueSlug(title, null);
    }

    private String generateUniqueSlug(String title, String currentSlug) {
        String base = toSlug(title);
        String slug = base;

        if (slug.equals(currentSlug)) {
            return currentSlug;
        }

        int counter = 1;
        while (blogRepository.existsBySlug(slug)) {
            slug = base + "-" + counter++;
        }
        return slug;
    }

    private String toSlug(String input) {
        String normalized = Normalizer.normalize(input, Normalizer.Form.NFD);
        String slug = WHITESPACE.matcher(normalized).replaceAll("-");
        slug = NON_LATIN.matcher(slug).replaceAll("");
        return slug.toLowerCase(Locale.ENGLISH).replaceAll("-{2,}", "-").replaceAll("^-|-$", "");
    }
}
