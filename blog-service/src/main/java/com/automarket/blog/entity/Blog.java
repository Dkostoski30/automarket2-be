package com.automarket.blog.entity;

import com.automarket.common.entity.AuditableEntity;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "blogs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Blog extends AuditableEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(nullable = false, unique = true, length = 200)
    private String slug;

    @Column(nullable = false, length = 500)
    private String excerpt;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(name = "cover_image_url", length = 1024)
    private String coverImageUrl;

    @Column(name = "cover_image_key", length = 1024)
    private String coverImageKey;

    @Column(nullable = false)
    @Builder.Default
    private Boolean published = false;

    /**
     * Author stored as UUID only — no JPA FK to users table.
     * Author name is enriched at runtime via AuthorView (Phase 2: same DB)
     * or via auth-service Feign client (Phase 4+: separate DB).
     */
    @Column(name = "author_id")
    private UUID authorId;
}
