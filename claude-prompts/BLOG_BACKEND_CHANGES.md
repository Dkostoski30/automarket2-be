# Blog Feature — Required Backend Changes

The frontend blog feature expects the following API endpoints. This document describes what needs to be added or modified on the backend.

---

## Existing Endpoints (verify they exist)

These are already called by the FE and should be in place:

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/api/v1/blog?page=0&size=6` | Public | Paginated blog list. Returns `PageResponse<BlogPostDto>` |
| `GET` | `/api/v1/blog/{id}` | Public | Single blog post by ID |
| `GET` | `/api/v1/blog/slug/{slug}` | Public | Single blog post by slug |
| `POST` | `/api/v1/blog` | MODERATOR, ADMIN | Create a blog post |
| `PUT` | `/api/v1/blog/{id}` | MODERATOR, ADMIN | Update a blog post |
| `DELETE` | `/api/v1/blog/{id}` | MODERATOR, ADMIN | Delete a blog post |

---

## New Endpoints to Add

### 1. Upload Blog Cover Image

```
POST /api/v1/blog/{id}/cover-image
```

- **Auth**: `ROLE_MODERATOR` or `ROLE_ADMIN`
- **Content-Type**: `multipart/form-data`
- **Form field**: `file` (single image file)
- **Max size**: 10 MB
- **Accepted types**: `image/jpeg`, `image/png`, `image/webp`
- **Behavior**:
  - Upload the file to your storage (S3, local filesystem, etc.)
  - Update the blog post's `coverImageUrl` field with the resulting public URL
  - If a previous cover image exists, optionally delete the old file from storage
  - Return the updated `BlogPostDto`
- **Response**: `200 OK` — `BlogPostDto`
- **Errors**: `404` if blog post not found, `400` if file is invalid/too large, `403` if unauthorized

**Example controller (Spring Boot):**
```java
@PostMapping("/{id}/cover-image")
@PreAuthorize("hasAnyRole('MODERATOR', 'ADMIN')")
public ResponseEntity<BlogPostDto> uploadCoverImage(
        @PathVariable UUID id,
        @RequestParam("file") MultipartFile file) {
    BlogPostDto updated = blogService.uploadCoverImage(id, file);
    return ResponseEntity.ok(updated);
}
```

---

### 2. Upload Blog Content Image

```
POST /api/v1/blog/images
```

- **Auth**: `ROLE_MODERATOR` or `ROLE_ADMIN`
- **Content-Type**: `multipart/form-data`
- **Form field**: `file` (single image file)
- **Max size**: 10 MB
- **Accepted types**: `image/jpeg`, `image/png`, `image/webp`
- **Behavior**:
  - Upload the file to storage (e.g. under a `/blog/content/` prefix)
  - Return the public URL of the uploaded image
  - These images are not tied to a specific blog post — they're used inline in blog HTML content
- **Response**: `200 OK`
  ```json
  {
    "url": "https://your-storage.com/blog/content/abc123.jpg"
  }
  ```
- **Errors**: `400` if file is invalid/too large, `403` if unauthorized

**Example controller (Spring Boot):**
```java
@PostMapping("/images")
@PreAuthorize("hasAnyRole('MODERATOR', 'ADMIN')")
public ResponseEntity<Map<String, String>> uploadContentImage(
        @RequestParam("file") MultipartFile file) {
    String url = imageStorageService.upload(file, "blog/content");
    return ResponseEntity.ok(Map.of("url", url));
}
```

---

## BlogPostDto — Expected Shape

The frontend expects blog post responses to match this structure:

```json
{
  "id": "uuid-string",
  "title": "Post Title",
  "slug": "post-title",
  "excerpt": "Short summary for listing cards",
  "content": "<p>Full HTML content of the blog post...</p>",
  "coverImageUrl": "https://storage.example.com/blog/covers/abc.jpg",
  "author": {
    "id": "uuid-string",
    "name": "Author Name"
  },
  "published": true,
  "createdAt": "2026-03-20T10:30:00Z",
  "updatedAt": "2026-03-22T14:00:00Z"
}
```

---

## CreateBlogPostRequest — Expected Body

```json
{
  "title": "string (required)",
  "excerpt": "string (required)",
  "content": "string (required, HTML)",
  "coverImageUrl": "string (optional, set later via cover-image upload)"
}
```

The `author` should be derived from the authenticated user on the backend. The `slug` should be auto-generated from the title.

---

## UpdateBlogPostRequest — Expected Body

```json
{
  "title": "string (optional)",
  "excerpt": "string (optional)",
  "content": "string (optional)",
  "coverImageUrl": "string (optional)",
  "published": "boolean (optional)"
}
```

---

## Storage Notes

- Reuse the same storage service/config you use for listing images
- Suggested storage paths:
  - Cover images: `blog/covers/{blogId}/{filename}`
  - Content images: `blog/content/{uuid}.{ext}`
- Content images don't need cleanup when a post is deleted (they're referenced by URL in HTML), but cover images should be cleaned up on post deletion

---

## Multipart Config

If your Spring Boot config limits file upload size, ensure it allows at least 10 MB:

```yaml
spring:
  servlet:
    multipart:
      max-file-size: 10MB
      max-request-size: 10MB
```