package com.automarket.blog.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

/**
 * Local read model of a blog author, owned by blog-service.
 *
 * <p>Previously mapped onto auth-service's `users` table. It now maps onto
 * blog_author_view, kept current by UserEventConsumer from the user-events topic.
 *
 * <p>Rows are never deleted when a user is deleted: historical posts should keep
 * showing who wrote them.
 */
@Entity
@Table(name = "blog_author_view")
@Getter
@Setter
@NoArgsConstructor
public class AuthorView {

    @Id
    private UUID id;

    private String name;

    private String email;
}
