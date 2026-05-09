# Backend Changes Required: Admin User Management & SUPERADMIN Role

This document describes all backend changes needed to support the new **Admin User Management** feature and the **ROLE_SUPERADMIN** role in the frontend.

---

## 1. New Role: `ROLE_SUPERADMIN`

### What it is
A role above `ROLE_ADMIN` with unrestricted access to all platform features, including the ability to:
- Assign/revoke `ROLE_ADMIN` and `ROLE_SUPERADMIN` roles
- Delete user accounts permanently
- Access every feature that `ROLE_ADMIN` and `ROLE_MODERATOR` can access

### Role Hierarchy (top → bottom)
| Role | Inherits from | Special Abilities |
|------|--------------|-------------------|
| `ROLE_SUPERADMIN` | ADMIN, MODERATOR, USER | Delete users, assign ADMIN/SUPERADMIN roles |
| `ROLE_ADMIN` | MODERATOR, USER | User management (view, edit roles up to MODERATOR, enable/disable) |
| `ROLE_MODERATOR` | USER | Listing moderation (approve/reject), blog management |
| `ROLE_USER` | — | Create listings, manage own profile/listings |

### Database Changes

Add `ROLE_SUPERADMIN` to the roles table/enum. Seed one initial superadmin account.

```sql
-- If using a roles enum/table:
INSERT INTO roles (name) VALUES ('ROLE_SUPERADMIN');

-- Assign to initial admin user (adjust ID as needed):
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email = 'admin@automarket.mk' AND r.name = 'ROLE_SUPERADMIN';
```

### Spring Security Configuration

Update the role hierarchy if using one:

```java
@Bean
public RoleHierarchy roleHierarchy() {
    RoleHierarchyImpl hierarchy = new RoleHierarchyImpl();
    hierarchy.setHierarchy("""
        ROLE_SUPERADMIN > ROLE_ADMIN
        ROLE_ADMIN > ROLE_MODERATOR
        ROLE_MODERATOR > ROLE_USER
    """);
    return hierarchy;
}
```

Update any `@PreAuthorize` or `@Secured` annotations on existing admin endpoints to also allow `ROLE_SUPERADMIN`:
- All `ROLE_ADMIN` endpoints should also accept `ROLE_SUPERADMIN`
- All `ROLE_MODERATOR` endpoints should also accept `ROLE_ADMIN` and `ROLE_SUPERADMIN`

> If you already use role hierarchy, this happens automatically. If you use explicit role checks, add `ROLE_SUPERADMIN` alongside `ROLE_ADMIN`.

---

## 2. New DTO: `AdminUserDto`

The frontend expects this shape when listing users in the admin panel:

```java
public record AdminUserDto(
    String id,
    String email,
    String name,
    String phone,        // nullable
    String cityName,     // nullable
    String plan,         // "FREE" or "PREMIUM"
    List<String> roles,  // e.g. ["ROLE_USER", "ROLE_ADMIN"]
    String createdAt,    // ISO 8601
    int totalListings,   // count of ALL listings by this user
    int activeListings,  // count of APPROVED/active listings only
    boolean enabled      // account enabled flag
) {}
```

### Listing Counts
- `totalListings`: `SELECT COUNT(*) FROM listings WHERE seller_id = :userId`
- `activeListings`: `SELECT COUNT(*) FROM listings WHERE seller_id = :userId AND status = 'APPROVED'`

These can be fetched via a JOIN or a subquery when building the paginated user list.

---

## 3. New REST Endpoints

All endpoints under `/api/admin/users` require `ROLE_ADMIN` or `ROLE_SUPERADMIN`.

### 3.1 `GET /api/admin/users`

**Purpose:** Paginated list of all users with listing counts.

**Auth:** `ROLE_ADMIN`, `ROLE_SUPERADMIN`

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | int | 0 | Page number (0-based) |
| `size` | int | 20 | Page size |
| `search` | string | null | Optional search term — filter by `name ILIKE %search%` OR `email ILIKE %search%` |

**Response:** `PageResponse<AdminUserDto>` (same pagination wrapper used for listings)

```json
{
  "content": [
    {
      "id": "uuid",
      "email": "user@example.com",
      "name": "John Doe",
      "phone": "+38970123456",
      "cityName": "Skopje",
      "plan": "FREE",
      "roles": ["ROLE_USER"],
      "createdAt": "2025-01-15T10:30:00Z",
      "totalListings": 5,
      "activeListings": 3,
      "enabled": true
    }
  ],
  "totalElements": 150,
  "totalPages": 8,
  "number": 0,
  "size": 20
}
```

**Sort:** Default by `createdAt DESC` (newest users first).

### 3.2 `GET /api/admin/users/{id}`

**Purpose:** Get a single user's full admin detail.

**Auth:** `ROLE_ADMIN`, `ROLE_SUPERADMIN`

**Response:** `AdminUserDto`

**Errors:**
- `404` if user not found

### 3.3 `PUT /api/admin/users/{id}/roles`

**Purpose:** Update a user's roles.

**Auth:** `ROLE_ADMIN`, `ROLE_SUPERADMIN`

**Request Body:**
```json
{
  "roles": ["ROLE_USER", "ROLE_MODERATOR"]
}
```

**Business Rules:**
1. `ROLE_USER` must always be present (cannot remove base role)
2. Only `ROLE_SUPERADMIN` can assign/revoke `ROLE_ADMIN` or `ROLE_SUPERADMIN`
3. `ROLE_ADMIN` can only assign/revoke `ROLE_MODERATOR`
4. A user cannot change their own roles
5. A `ROLE_SUPERADMIN` user's roles cannot be changed by a `ROLE_ADMIN`

**Response:** Updated `AdminUserDto`

**Errors:**
- `400` if `ROLE_USER` is missing from the array
- `403` if caller lacks permission to assign the requested roles
- `403` if trying to modify own roles
- `404` if user not found

### 3.4 `PUT /api/admin/users/{id}/status`

**Purpose:** Enable or disable a user account.

**Auth:** `ROLE_ADMIN`, `ROLE_SUPERADMIN`

**Request Body:**
```json
{
  "enabled": false
}
```

**Business Rules:**
1. Cannot disable your own account
2. `ROLE_ADMIN` cannot disable a `ROLE_SUPERADMIN` user
3. `ROLE_ADMIN` cannot disable another `ROLE_ADMIN` (only `ROLE_SUPERADMIN` can)
4. When disabled, the user's existing refresh tokens should be invalidated
5. Disabled users should receive `403` on all authenticated requests

**Response:** Updated `AdminUserDto`

**Errors:**
- `403` if caller lacks permission
- `404` if user not found

### 3.5 `DELETE /api/admin/users/{id}`

**Purpose:** Permanently delete a user and all their data.

**Auth:** `ROLE_SUPERADMIN` only

**Business Rules:**
1. Only `ROLE_SUPERADMIN` can delete users
2. Cannot delete your own account
3. Cascade-delete or handle:
   - User's listings (and their images)
   - User's favorites
   - User's sent/received inquiries
   - User's refresh tokens
   - Blog posts authored by the user (if applicable)
4. Consider soft-delete as an alternative (add `deletedAt` timestamp)

**Response:** `204 No Content`

**Errors:**
- `403` if caller is not `ROLE_SUPERADMIN`
- `403` if trying to delete self
- `404` if user not found

---

## 4. Update Existing `GET /api/admin/dashboard`

Add the user count breakdown to the dashboard stats response if not already present. The frontend currently reads `totalUsers` — no change needed there, but consider adding:

```json
{
  "pendingListings": 12,
  "approvedListings": 340,
  "totalUsers": 150,
  "activeUsers": 145,
  "disabledUsers": 5,
  "totalBrands": 42,
  "totalBlogs": 8
}
```

---

## 5. Update User Entity

If the `enabled` field doesn't exist yet on the User entity:

```java
@Entity
@Table(name = "users")
public class User {
    // ... existing fields ...

    @Column(nullable = false)
    private boolean enabled = true;  // Add this field
}
```

```sql
-- Migration:
ALTER TABLE users ADD COLUMN enabled BOOLEAN NOT NULL DEFAULT true;
```

Ensure Spring Security's `UserDetails.isEnabled()` returns this field so that disabled users are automatically rejected at authentication time.

---

## 6. Authentication Changes

### Token Validation
When a user is disabled (`enabled = false`):
- Reject login attempts with `403` and a clear error message
- Invalidate existing refresh tokens
- Any request with a valid access token should still check `enabled` status (since tokens are short-lived this may be acceptable to skip, but for immediate effect, add a check)

### JWT Claims
Consider adding `roles` to the JWT claims if not already there, so the frontend can decode the token without calling `/users/me`. If roles change, the user's current access token will still carry the old roles until it expires — this is acceptable given short expiry times.

---

## 7. Security Checklist

- [ ] All `/api/admin/users/**` endpoints require `ROLE_ADMIN` or `ROLE_SUPERADMIN`
- [ ] `DELETE /api/admin/users/{id}` requires `ROLE_SUPERADMIN` only
- [ ] Role assignment is properly scoped (ADMIN can only assign up to MODERATOR)
- [ ] Users cannot modify their own roles or disable themselves
- [ ] ADMIN cannot modify SUPERADMIN users
- [ ] Disabled users cannot authenticate
- [ ] Pagination is enforced (max page size ~50)
- [ ] Search parameter is sanitized (no SQL injection via ILIKE)
- [ ] Audit logging for role changes and account disable/delete actions

---

## 8. Summary of New Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/api/admin/users` | ADMIN, SUPERADMIN | Paginated user list with search |
| `GET` | `/api/admin/users/{id}` | ADMIN, SUPERADMIN | Single user detail |
| `PUT` | `/api/admin/users/{id}/roles` | ADMIN, SUPERADMIN | Update user roles |
| `PUT` | `/api/admin/users/{id}/status` | ADMIN, SUPERADMIN | Enable/disable user |
| `DELETE` | `/api/admin/users/{id}` | SUPERADMIN | Permanently delete user |

---

## 9. Frontend Expectations

The frontend is already built and expects:
- `PageResponse<AdminUserDto>` format (same as listings pagination: `content`, `totalElements`, `totalPages`, `number`, `size`)
- Roles as strings: `ROLE_USER`, `ROLE_MODERATOR`, `ROLE_ADMIN`, `ROLE_SUPERADMIN`
- `plan` as string: `FREE` or `PREMIUM`
- `createdAt` as ISO 8601 string
- Standard HTTP error codes (400, 403, 404) for validation/permission errors
