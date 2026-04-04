---
name: "dotnet-authn-authz"
description: "ASP.NET Core authentication and authorization review. Covers server-enforced authorization, claims/policy/role review, token and cookie handling, identity flow analysis, and common .NET auth misconfigurations."
domain: "security"
confidence: "high"
source: "manual — authored from canonical references"
---

## Context

This skill provides deep, .NET-specific guidance for reviewing authentication and authorization in ASP.NET Core applications — APIs, Blazor Server, Blazor Web Apps, and Blazor WebAssembly. It complements `security-review-core` (review framework and output schema) and `owasp-secure-code-review` (general manual review methodology) with platform-specific patterns, anti-patterns, and misconfigurations.

**Core principle:** Server enforcement is the only meaningful enforcement boundary. Client-side checks — hidden buttons, Angular guards, Blazor `[Authorize]` on a component — are UI hints, not security controls. Every authorization decision that matters must be enforced server-side at the API or service layer.

## Best used for

- **ASP.NET Core APIs** — reviewing endpoint protection, policy enforcement, and token handling
- **Blazor Server and Blazor Web Apps** — verifying server-side auth enforcement, not just component-level attributes
- **Blazor WebAssembly** — ensuring the API boundary is the security boundary, not the WASM client
- **PR review of any auth-related change** — new endpoints, policy changes, JWT configuration, cookie configuration
- **Identity flow analysis during design review** — OIDC/OAuth integration, token lifecycle, session management
- **Auth-heavy services** — multi-tenant systems, role-based and policy-based access control, API gateway authorization

## Primary references

- [ASP.NET Core Blazor authentication and authorization](https://learn.microsoft.com/en-us/aspnet/core/blazor/security/?view=aspnetcore-10.0)
- [Secure ASP.NET Core Blazor WebAssembly](https://learn.microsoft.com/en-us/aspnet/core/blazor/security/webassembly/?view=aspnetcore-10.0)
- [ASP.NET Core Blazor WebAssembly additional security scenarios](https://learn.microsoft.com/en-us/aspnet/core/blazor/security/webassembly/additional-scenarios?view=aspnetcore-10.0)
- [ASP.NET Core server-side and Blazor Web App additional security scenarios](https://learn.microsoft.com/en-us/aspnet/core/blazor/security/additional-scenarios?view=aspnetcore-10.0)

## Patterns

### ASP.NET Core middleware order

Middleware order determines whether authentication and authorization actually run. If the order is wrong, `[Authorize]` attributes silently do nothing.

**Required order in `Program.cs` / `Startup.cs`:**

```csharp
app.UseRouting();           // must come before auth
app.UseAuthentication();    // must come before UseAuthorization
app.UseAuthorization();     // must come before endpoint handlers
app.MapControllers();       // after auth middleware
```

**What to flag:**

- `UseAuthorization()` missing entirely — `[Authorize]` attributes are ignored
- `UseAuthentication()` present without `UseAuthorization()` — identity is populated but never enforced
- `UseAuthorization()` placed before `UseRouting()` — authorization runs without route context
- `MapControllers()` or `MapRazorPages()` placed before auth middleware — endpoints register before auth is wired

### [Authorize] coverage

Every endpoint must be either explicitly authorized or explicitly anonymous — there must be no implicit defaults.

**Review checklist:**

- Does the application use `[Authorize]` at the controller/class level with `[AllowAnonymous]` exceptions? This is the preferred pattern (deny-by-default).
- Are there endpoints with neither `[Authorize]` nor `[AllowAnonymous]`? These rely on implicit behavior and must be made explicit.
- Is `[AllowAnonymous]` left on endpoints from development or scaffolding?
- For minimal APIs: is `.RequireAuthorization()` applied to route groups? Are new routes missing `.RequireAuthorization()`?

**Policy vs role vs claim:**

Prefer policy-based authorization over role strings:

```csharp
// Preferred — composable, unit-testable, refactorable
[Authorize(Policy = "CanManageUsers")]

// Avoid — magic strings, not composable, hard to test
[Authorize(Roles = "Admin")]
```

Policies are defined in `Program.cs` and can combine multiple requirements. Role strings are scattered across controllers and cannot be unit-tested without spinning up the full auth stack.

### Claims and policy review

- **Claim validation:** Are claims validated server-side on every request? Claims in JWTs can be tampered with if signature validation is weak.
- **Policy requirements:** Are policies actually enforced in `IAuthorizationHandler` implementations? A registered policy with no handler defaults to denied — but verify this is intentional.
- **Custom policy handlers:** Do they correctly call `context.Fail()` on failure? A handler that only calls `context.Succeed()` on success but does nothing on failure leaves the door open for other handlers to succeed.
- **Claim type mapping:** ASP.NET Core maps JWT `sub` → `ClaimTypes.NameIdentifier` by default. Verify the correct claim type is used in ownership checks. Mismatched claim types silently return null, bypassing authorization.

### Token handling review

**JWT validation — `TokenValidationParameters`:**

All four validations must be enabled. Any one set to `false` is a finding:

| Parameter | Required value | Risk if disabled |
|---|---|---|
| `ValidateIssuer` | `true` | Tokens from any issuer accepted |
| `ValidateAudience` | `true` | Tokens intended for other services accepted |
| `ValidateLifetime` | `true` | Expired tokens accepted indefinitely |
| `ValidateIssuerSigningKey` | `true` | Tokens with invalid signatures accepted |

**Additional token checks:**

- `ValidAudience` must be set to the application's own audience — prevents cross-service token reuse
- Token storage in Blazor WASM: tokens must not be stored in `localStorage` (XSS risk). Prefer in-memory storage or `sessionStorage` with short lifetimes. Secure HTTP-only cookies are preferred for API authentication.
- Bearer token transmission: always over HTTPS only. Never in URL query strings (logged by proxies, browser history, referrer headers).
- Refresh tokens: must be rotated on use. Implement reuse detection — if a refresh token is used twice, revoke the entire token family.

### Cookie handling review

Review cookie configuration for these security attributes:

| Attribute | Required value | Risk if missing |
|---|---|---|
| `HttpOnly` | `true` | JavaScript can read the cookie — XSS token theft |
| `Secure` | `true` | Cookie sent over HTTP — network interception |
| `SameSite` | `Strict` or `Lax` | Cross-site requests include the cookie — CSRF |

**Additional cookie checks:**

- `.AspNetCore.Antiforgery` cookie should also have `Secure = true`
- Session cookie lifetime: use short absolute timeouts for sensitive applications, not just sliding expiration
- Sliding expiration without absolute timeout: a session can be kept alive indefinitely by continuous activity
- Cookie domain: should not be set broader than necessary (e.g., `.example.com` when only `app.example.com` is needed)

### OIDC / OAuth flow review

**Required flow:** Authorization Code Flow with PKCE for public clients (SPAs, mobile apps, Blazor WASM).

**What to flag:**

| Issue | Severity | Detail |
|---|---|---|
| Implicit flow in use | High | Deprecated — tokens exposed in URL fragment. Migrate to Auth Code + PKCE. |
| Missing `state` parameter validation | High | CSRF on the OAuth callback — attacker can inject their own authorization code. |
| Missing `nonce` validation in ID token | Medium | Replay attack — a captured ID token can be reused. |
| Wildcard redirect URIs | Critical | Open redirect — attacker can steal authorization codes by registering a malicious redirect. |
| Non-exact-match redirect URIs | High | Redirect URI must be exact-match registered. Substring or pattern matching allows bypass. |
| Client secret in client-side code | Critical | Secret is public — use PKCE instead of client secret for public clients. |

### API authorization boundary — IDOR prevention

For every data read and write operation, verify that the caller is authorised to access *this specific record*, not just the type of record.

**Pattern to flag (vulnerable):**

```csharp
// No ownership check — any authenticated user can access any order
var order = await db.Orders.FindAsync(orderId);
```

**Correct pattern:**

```csharp
// Ownership check — user can only access their own orders
var order = await db.Orders.FirstOrDefaultAsync(
    o => o.Id == orderId && o.UserId == currentUserId);
```

**Multi-tenant systems:**

- Tenant ID must be added to every query at the data access layer (e.g., via a global query filter in EF Core)
- Do not rely on individual callers to remember to filter by tenant — this is an architectural requirement, not a per-query responsibility
- Verify that global query filters cannot be bypassed with `IgnoreQueryFilters()` in application code

### Blazor-specific authorization

**Blazor Server / Blazor Web App:**

- `[Authorize]` on a component controls rendering, not access. The server-side circuit still processes hub messages — ensure authorization is enforced in the service/data layer, not just the component tree.
- `AuthenticationStateProvider` is available server-side — use it, but verify it is backed by real middleware, not a stub.

**Blazor WebAssembly:**

- The WASM client is untrusted. All authorization decisions must be enforced at the API boundary.
- `[Authorize]` on a WASM component is a UI hint — it hides UI elements but does not prevent API calls.
- `AuthenticationStateProvider` in WASM reads claims from the token — but the API must independently validate the token and enforce authorization.
- Never put secrets, API keys, or admin logic in WASM client code — it is fully inspectable.

## Anti-Patterns

- **Trusting `[Authorize]` on a Blazor component as a security boundary.** It is a UI hint. The API or service layer must enforce authorization independently.
- **Using `[Authorize(Roles = "Admin")]` with hardcoded role strings.** Use policy-based authorization — it is composable, testable, and refactorable. Role strings scattered across controllers are fragile and hard to audit.
- **Setting `ValidateAudience = false` in JWT configuration.** This allows tokens issued for other services to be accepted — a cross-service impersonation risk.
- **Storing tokens in `localStorage` in Blazor WASM.** XSS vulnerabilities allow token theft. Use in-memory storage, `sessionStorage`, or secure HTTP-only cookies.
- **Placing `UseAuthorization()` before `UseRouting()`.** Authorization runs without route context and `[Authorize]` attributes are silently ignored.
- **Relying on client-side validation for auth decisions.** Hidden buttons, disabled links, and client-side route guards are UX features, not security controls.
- **Checking authentication without checking authorization.** "Is the user logged in?" is not the same as "Is this user allowed to access this resource?"
- **Using `IgnoreQueryFilters()` without understanding the security implications.** In multi-tenant systems, this bypasses tenant isolation.

## Examples

### Example: middleware order finding

```
### UseAuthorization() missing from middleware pipeline

- **Severity:** Critical
- **Confidence:** High
- **Category:** Misconfiguration
- **Affected files/components:** `src/Program.cs`
- **Why it matters:** The application calls `UseAuthentication()` but not `UseAuthorization()`. All `[Authorize]` attributes on controllers and endpoints are silently ignored. Every endpoint is effectively anonymous.
- **CWE / OWASP:** CWE-862 (Missing Authorization), OWASP A01:2021
- **Recommended fix:** Add `app.UseAuthorization();` after `app.UseAuthentication();` and before `app.MapControllers();` in `Program.cs`.
- **Re-review required:** Yes
```

### Example: IDOR finding

```
### Missing ownership check on order retrieval

- **Severity:** High
- **Confidence:** High
- **Category:** Implementation flaw
- **Affected files/components:** `src/Features/Orders/GetOrderHandler.cs`, `GET /api/orders/{id}`
- **Why it matters:** The endpoint retrieves an order by ID without verifying that the authenticated user owns the order. Any authenticated user can access any other user's order by enumerating order IDs.
- **CWE / OWASP:** CWE-639 (Authorization Bypass Through User-Controlled Key), OWASP API1:2023
- **Recommended fix:** Add `&& o.UserId == currentUserId` to the query filter. Return 404 (not 403) when the order is not found — this prevents information leakage about order existence.
- **Re-review required:** Yes
```

### Example: JWT misconfiguration finding

```
### JWT audience validation disabled

- **Severity:** High
- **Confidence:** High
- **Category:** Misconfiguration
- **Affected files/components:** `src/Program.cs`, JWT bearer configuration
- **Why it matters:** `TokenValidationParameters.ValidateAudience` is set to `false`. Tokens issued for other services in the same identity provider can be used to authenticate to this API, enabling cross-service impersonation.
- **CWE / OWASP:** CWE-287 (Improper Authentication), OWASP A07:2021
- **Recommended fix:** Set `ValidateAudience = true` and configure `ValidAudience` to match this application's registered audience identifier in the identity provider.
- **Re-review required:** Yes
```

### Example: Blazor WASM trust boundary finding

```
### Admin functionality implemented in Blazor WASM client

- **Severity:** Critical
- **Confidence:** High
- **Category:** Architectural flaw
- **Affected files/components:** `src/Client/Pages/Admin/ManageUsers.razor`, `src/Client/Services/AdminService.cs`
- **Why it matters:** The admin user management page includes business logic for role assignment and user deactivation in the WASM client code. The API endpoint `/api/admin/users` exists but does not enforce admin authorization — it relies on the WASM component's `[Authorize(Roles = "Admin")]` attribute, which is a client-side UI hint only.
- **CWE / OWASP:** CWE-602 (Client-Side Enforcement of Server-Side Security), OWASP A01:2021
- **Recommended fix:** Move all authorization checks to the API controller or handler. Add `[Authorize(Policy = "AdminOnly")]` to the API endpoint. The WASM component's `[Authorize]` can remain as a UX convenience but must not be the security boundary.
- **Re-review required:** Yes
```

## Review cues

Trigger this skill when:

- A PR adds, modifies, or removes authentication or authorization configuration
- New endpoints are added — verify `[Authorize]` or `.RequireAuthorization()` coverage
- JWT, cookie, or OIDC configuration is changed
- A Blazor component uses `[Authorize]` — verify the API boundary enforces it too
- Multi-tenant data access patterns are added or modified
- `Program.cs` or `Startup.cs` middleware pipeline is changed
- Policy definitions, role assignments, or claim mappings are modified
- Token storage or transmission patterns change
- An IDOR vulnerability is suspected or has been reported

## Good looks like

An excellent auth review using this skill:

1. **Verifies middleware order first** — confirms `UseAuthentication()` → `UseAuthorization()` → endpoint mapping sequence in `Program.cs`
2. **Audits every endpoint for explicit auth** — no endpoint relies on implicit defaults; every one is `[Authorize]` or `[AllowAnonymous]`
3. **Checks JWT validation parameters** — all four validation flags are `true`, audience is set correctly
4. **Traces the authorization boundary in Blazor** — confirms the API enforces auth independently of any client-side `[Authorize]` attributes
5. **Validates object-level authorization** — every data access includes an ownership/tenant check, not just endpoint-level auth
6. **Reviews cookie security attributes** — `HttpOnly`, `Secure`, `SameSite` are all correctly configured
7. **Checks OIDC flow** — confirms Authorization Code + PKCE, validates `state` and `nonce`, exact-match redirect URIs
8. **Documents findings in the standard schema** — uses the `security-review-core` output format with all required fields

## Common findings / likely remediations

| Finding | Severity | Remediation |
|---------|----------|-------------|
| `[AllowAnonymous]` left on endpoint accidentally | High | Remove `[AllowAnonymous]`. Add `[Authorize]` with appropriate policy. Review git history to confirm it was unintentional. |
| `UseAuthentication()` present without `UseAuthorization()` | Critical | Add `app.UseAuthorization()` after `app.UseAuthentication()` in `Program.cs`. |
| JWT `ValidateAudience = false` | High | Set `ValidateAudience = true` and configure `ValidAudience` to the application's registered audience. |
| Missing ownership check — IDOR vulnerability | High | Add `UserId == currentUserId` (or tenant filter) to every data access query. Return 404 on not found. |
| `User.IsInRole()` with hardcoded strings | Medium | Migrate to policy-based authorization. Define policies in `Program.cs`, reference by policy name. |
| Blazor component `[Authorize]` as sole security boundary | Critical | Add `[Authorize(Policy = "...")]` to the API endpoint. Component `[Authorize]` is a UI hint only. |
| Cookie auth without `SameSite` configured | Medium | Set `SameSite = SameSiteMode.Strict` (or `Lax` if cross-site navigation is needed) on cookie options. |
| Token stored in `localStorage` in WASM app | High | Move to in-memory token storage or secure HTTP-only cookies for API authentication. |
| Implicit OAuth flow in use | High | Migrate to Authorization Code Flow with PKCE. Update identity provider redirect configuration. |
| `IgnoreQueryFilters()` bypassing tenant isolation | Critical | Remove or gate `IgnoreQueryFilters()` behind admin-only authorization. Add code review requirement for any use. |
