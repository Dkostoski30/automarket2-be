package com.automarket.blog.repository;

import com.automarket.blog.entity.Blog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;
import java.util.UUID;

public interface BlogRepository extends JpaRepository<Blog, UUID> {

    @Query("SELECT b FROM Blog b ORDER BY b.createdAt DESC")
    Page<Blog> findAllOrderByCreatedAtDesc(Pageable pageable);

    Optional<Blog> findBySlug(String slug);

    boolean existsBySlug(String slug);

    long countByAuthorId(UUID authorId);
}
