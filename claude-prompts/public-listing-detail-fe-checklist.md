# FE Changes Needed: Public Listing Detail View

## Backend Changes Made
- Added `/api/v1/listings/slug/{slug}` and `/api/v1/listings/featured` to public endpoints
- `GET /api/v1/listings/{id}` was already public
- Anonymous users can now access listing detail pages without a JWT token

## FE Implementation Checklist

### 1. Auth Guard / Route Protection
- [ ] The listing detail route (e.g. `/listings/:slug` or `/listings/:id`) must NOT require authentication
- [ ] If there is a global auth guard or HTTP interceptor that redirects to login on 401, ensure the listing detail page is excluded or handles missing tokens gracefully

### 2. HTTP Interceptor
- [ ] If the Angular/React HTTP interceptor attaches a JWT `Authorization` header to every request, it should still work — the backend ignores the header for public endpoints. No change needed here, but verify it doesn't error if no token exists.

### 3. Conditional UI Elements (View-Only Mode)
The listing detail page should hide or disable the following for unauthenticated users:
- [ ] **Favorite button** (heart/save) — hide or show a "Login to save" tooltip
- [ ] **Contact seller button** — either hide phone/email or show with a "Login to contact" prompt
- [ ] **Edit/Delete buttons** — these should already be owner-only, just confirm they're hidden when no user is logged in
- [ ] **Report listing** — hide or prompt login

### 4. Seller Contact Info
- [ ] Decide whether to show seller phone number to anonymous users or mask it (e.g. `06X XXX XX**`) with a "Login to see full number" CTA
- [ ] The backend currently returns full seller phone in `ListingDetailDto.SellerDetailDto` — if you want to hide it for anonymous users, a backend change would be needed (optional)

### 5. Navigation
- [ ] "Back to my listings" or similar user-context links should not appear for anonymous users
- [ ] Login/Register CTA should be visible in the header when not logged in

### 6. Analytics
- [ ] View tracking (`analyticsService.recordView`) works for anonymous users on the backend — no FE change needed
- [ ] If FE sends any user-specific analytics events, guard those behind auth checks

### 7. SEO / SSR (If Applicable)
- [ ] Since listing detail is now fully public, ensure it's crawlable (meta tags, Open Graph, etc.)
- [ ] If using SSR (Angular Universal / Next.js), the page should render without a user session

### 8. Error Handling
- [ ] If the FE currently redirects to login on any API error, ensure 404 (listing not found) is handled differently from 401
- [ ] Expired/invalid tokens should not prevent viewing public listing pages

## Summary
The backend already serves listing detail data to anonymous users. The main FE work is ensuring route guards, interceptors, and conditional UI elements handle the unauthenticated state correctly.