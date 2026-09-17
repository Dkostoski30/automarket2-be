package com.automarket.blog.service;

import com.automarket.blog.dto.BlogAuthorDto;
import com.automarket.blog.dto.BlogDto;
import com.automarket.blog.dto.BlogRequest;
import com.automarket.blog.entity.AuthorView;
import com.automarket.blog.entity.Blog;
import com.automarket.blog.repository.AuthorRepository;
import com.automarket.blog.repository.BlogRepository;
import com.automarket.common.dto.PageResponse;
import com.automarket.common.exception.BusinessRuleException;
import com.automarket.common.exception.ResourceNotFoundException;
import com.automarket.storage.StorageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.text.Normalizer;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class BlogService {

    private final BlogRepository blogRepository;
    private final AuthorRepository authorRepository;
    private final StorageService storageService;

    private static final Pattern NON_LATIN  = Pattern.compile("[^\\w-]");
    private static final Pattern WHITESPACE = Pattern.compile("[\\s]+");

    @Transactional(readOnly = true)
    public PageResponse<BlogDto> list(int page, int size) {
        Page<Blog> blogPage = blogRepository.findAllOrderByCreatedAtDesc(PageRequest.of(page, size));
        Set<UUID> authorIds = blogPage.stream()
                .map(Blog::getAuthorId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        Map<UUID, BlogAuthorDto> authorMap = authorRepository.findAllById(authorIds).stream()
                .collect(Collectors.toMap(AuthorView::getId, a -> new BlogAuthorDto(a.getId(), a.getName())));
        return PageResponse.from(blogPage, b -> toDto(b, authorMap));
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
        AuthorView author = authorRepository.findByEmail(authorEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User", authorEmail));

        Blog blog = Blog.builder()
                .title(request.title())
                .slug(generateUniqueSlug(request.title()))
                .excerpt(request.excerpt())
                .content(request.content())
                .coverImageUrl(request.coverImageUrl())
                .published(request.published() != null ? request.published() : false)
                .authorId(author.getId())
                .build();

        blogRepository.save(blog);
        log.info("Blog created: {} by {}", blog.getId(), authorEmail);
        return toDto(blog);
    }

    @Transactional
    public BlogDto update(UUID id, BlogRequest request, String callerEmail, boolean isAdmin) {
        Blog blog = blogRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Blog", id));

        if (!isAdmin) {
            AuthorView caller = authorRepository.findByEmail(callerEmail)
                    .orElseThrow(() -> new ResourceNotFoundException("User", callerEmail));
            if (!blog.getAuthorId().equals(caller.getId())) {
                throw new BusinessRuleException("You are not the author of this blog post");
            }
        }

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

    @Transactional(readOnly = true)
    public long getBlogCount() {
        return blogRepository.count();
    }

    private BlogDto toDto(Blog b) {
        BlogAuthorDto authorDto = null;
        if (b.getAuthorId() != null) {
            authorDto = authorRepository.findById(b.getAuthorId())
                    .map(a -> new BlogAuthorDto(a.getId(), a.getName()))
                    .orElse(new BlogAuthorDto(b.getAuthorId(), "Unknown"));
        }
        return toDto(b, authorDto);
    }

    private BlogDto toDto(Blog b, Map<UUID, BlogAuthorDto> authorMap) {
        BlogAuthorDto authorDto = b.getAuthorId() != null
                ? authorMap.getOrDefault(b.getAuthorId(), new BlogAuthorDto(b.getAuthorId(), "Unknown"))
                : null;
        return toDto(b, authorDto);
    }

    private BlogDto toDto(Blog b, BlogAuthorDto authorDto) {
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
