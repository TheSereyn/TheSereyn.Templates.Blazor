---
name: "owasp-secure-code-review"
description: "OWASP secure code review methodology for .NET applications. Covers manual review techniques, entry-point analysis, data-flow thinking, and reviewer heuristics that automated scanners miss."
domain: "security"
confidence: "high"
source: "manual — authored from canonical references"
---

## Context

This skill provides OWASP methodology depth for manual secure code review. It complements `security-review-core`, which defines the review workflow (baseline vs diff mode), severity/confidence model, finding schema, and PR checklist. This skill adds the *how* — the techniques, thinking patterns, and heuristics a human reviewer applies when walking through code.

Use `security-review-core` for the review framework and output structure. Use this skill for the manual review methodology that fills that framework with findings.

## Best used for

- **All web apps and services** — especially when conducting manual review beyond what automated scanners cover
- **Pre-merge review of new endpoints or auth flow changes** — systematic entry-point and data-flow analysis
- **Periodic security audits of existing code** — comprehensive manual review using OWASP methodology
- **Business logic–heavy features** — where automated scanners provide limited coverage and human reasoning is essential
- **Review of multi-step flows** — purchase/payment/fulfilment, registration/verify/activate, and similar stateful processes

## Primary references

- [OWASP Secure Code Review Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secure_Code_Review_Cheat_Sheet.html)
- [OWASP Code Review Guide](https://owasp.org/www-project-code-review-guide/)

## Patterns

### Entry-point analysis

Identify ALL ingress points before reading implementation code. For each entry point, answer three questions: what data arrives? Is it validated? Who can call it?

**Ingress point inventory:**

| Ingress type | What to look for |
|---|---|
| HTTP endpoints — GET with query params | Query string values bound to action parameters or `[FromQuery]` |
| HTTP endpoints — POST/PUT/PATCH/DELETE body | Request body bound via `[FromBody]`, `[FromForm]`, or minimal API parameter binding |
| File upload handlers | `IFormFile`, multipart form data, streaming uploads |
| Webhook handlers | Callback endpoints accepting external system payloads (Stripe, GitHub, etc.) |
| Message queue consumers | `IHostedService`, MassTransit/NServiceBus consumers, Azure Service Bus handlers |
| Background job triggers | Hangfire jobs, Quartz.NET triggers, `IHostedService` with timed execution |
| Scheduled tasks | Cron-based or timer-based tasks that process external data on a schedule |
| SignalR hub methods | Methods on `Hub<T>` that accept client-supplied arguments |
| gRPC service methods | Service implementations accepting protobuf messages from clients |

**What to flag at each entry point:**

- Unauthenticated entry points that should require authentication
- Entry points that accept more fields than documented or intended — mass assignment risk
- Entry points with no input validation or only client-side validation
- Entry points that bind directly to domain entities instead of DTOs

### Data-flow thinking

Trace untrusted data from its entry point through the application to every destination it reaches.

**Key destinations to trace to:**

| Destination | Risk if unsanitised |
|---|---|
| Database queries | SQL injection, NoSQL injection |
| File system operations | Path traversal, arbitrary file write/overwrite |
| External HTTP calls | SSRF, header injection |
| Rendered output (HTML, JSON) | XSS, content injection |
| Log entries | Log injection, PII/secret leakage |
| Serialized objects | Insecure deserialization, type confusion |
| Email/SMS content | Content injection, phishing via application |
| Command-line arguments | Command injection |

**What to flag:**

- Any path where untrusted data reaches a destination without sanitisation, parameterisation, or encoding
- **Data laundering:** data is sanitised at input but stored raw, then fetched and used unsanitised later
- **Indirect data flows:** user input stored in database, later retrieved by a different component that assumes it is trusted
- **Partial sanitisation:** data is HTML-encoded but used in a SQL query, or SQL-parameterised but rendered as raw HTML

### Business logic review

**Multi-step flow analysis:**

- Identify flows with sequential steps: purchase → payment → fulfilment, registration → verify → activate
- Can steps be skipped? Can a user jump directly to step 3 without completing step 1?
- Can parameters from step 1 be tampered with in step 2? (e.g., price set in step 1, payment processed in step 2 — is the price re-validated?)
- Is step completion tracked server-side or inferred from client state?

**Rate limiting and abuse:**

- Can the same action be repeated infinitely? Check: password reset requests, OTP generation, login attempts, coupon redemption
- Is rate limiting enforced server-side, not just by the UI disabling a button?
- Are expensive operations (report generation, email sends, export jobs) rate-limited?

**State machine integrity:**

- Does the system enforce valid state transitions? Can an order go from "cancelled" back to "processing"?
- Are state transitions atomic? Can concurrent requests drive the system into an invalid state?

**Boundary value abuse:**

- What happens with minimum, maximum, zero, negative, or out-of-range values?
- Quantity = -1 in a cart? Amount = 0 on a payment? String length = 10 million characters?

### AuthN/authZ checks

- **Every endpoint:** Is authentication required? Is it enforced by middleware or attribute, not just assumed because the UI does not show the link?
- **Every data access:** Is the caller authorised to access THIS specific record, not just the type of record?
- **Privilege boundaries:** Can a user with role A invoke functionality meant for role B?
- **Horizontal IDOR:** Can user A access user B's data by changing an ID parameter in the URL or request body?
- **Vertical escalation:** Can a non-admin reach admin endpoints by calling them directly?
- **Implicit trust:** Does the code assume "if the user is authenticated, they are authorised"? Authentication ≠ authorisation.

### Cryptography review

- **Custom crypto:** Is any custom cryptographic code present? This is a red flag — always prefer framework/platform cryptography (ASP.NET Core Data Protection, `System.Security.Cryptography`)
- **Hash functions:** MD5 and SHA-1 are broken for security purposes. Only SHA-256 or stronger for integrity/security
- **Password hashing:** Only `PasswordHasher<T>` (ASP.NET Core Identity) or dedicated password hashing libraries (bcrypt, Argon2) — never plain SHA, HMAC, or unsalted hashing
- **Key material:** Is the key length appropriate for the algorithm? Are IVs/nonces generated correctly (cryptographically random, never reused)?
- **Certificates:** Check expiry, chain validation, and revocation checking. Is certificate pinning used where appropriate?

### Error handling review

- Do exceptions expose stack traces, internal file paths, or database schema to clients?
- Is `app.UseExceptionHandler()` or equivalent configured to sanitise error responses in production?
- `ProblemDetails` responses: are they stripping internal detail in production mode?
- Logging: do error logs include PII, tokens, secrets, or connection strings?
- Are different exception types handled appropriately, or does a generic catch-all swallow security-relevant exceptions silently?

### Manual reviewer heuristics — things scanners miss

These are the findings that justify manual review. Automated scanners rarely detect these patterns:

**Race conditions / TOCTOU:**
- Check-then-act patterns where the state can change between the check and the action
- Non-atomic operations on shared state (e.g., read balance → check sufficient → deduct — without a transaction or lock)
- Concurrent request handling: can two simultaneous requests both pass a check that should only allow one?

**Logic flaws:**
- Business rule bypasses — discount applied twice, coupon used after expiry, free tier limits circumvented
- Unsigned integer underflow — subtracting from zero wraps to a large positive number
- Order-of-operations errors — validation runs after the side effect, not before

**Trust confusion:**
- Code that trusts client-supplied values for server-side decisions (e.g., `isAdmin: true` in request body, `price` field in cart submission)
- Client-controlled redirect URLs without validation — open redirect
- Hidden form fields or client-side state used as authoritative data

**Insufficient logging:**
- No audit trail for sensitive actions: authentication failures, privilege use, data export, bulk operations, configuration changes
- Log entries that do not include enough context to reconstruct what happened (missing user ID, timestamp, or affected resource)

**Overly permissive defaults:**
- `[AllowAnonymous]` left on from development or scaffolding
- Default credentials not changed (database, admin panel, API keys)
- Debug endpoints or diagnostic middleware not removed before production (`/swagger` without auth, `/elmah`, `app.UseDeveloperExceptionPage()` without environment check)
- CORS configured with `AllowAnyOrigin()` in production

## Anti-Patterns

- **Reviewing only the happy path.** Security bugs live in edge cases, error paths, and boundary conditions — not in the main flow.
- **Trusting framework defaults without verifying.** ASP.NET Core has good defaults, but they must be explicitly configured — `UseAuthorization()` does nothing without `[Authorize]` attributes, and middleware order matters.
- **Treating sanitisation as a one-time event.** Data must be sanitised for its destination context every time it is used, not just when it enters the system.
- **Assuming authenticated = authorised.** A logged-in user is not automatically allowed to access every resource. Object-level authorisation must be checked on every data access.
- **Stopping at the first finding.** A single vulnerability may indicate a pattern. If one endpoint is missing `[Authorize]`, check all endpoints.
- **Ignoring indirect data flows.** Data stored in the database is still untrusted when it is fetched later — it may have been inserted via a different, less-validated path.
- **Skipping business logic review for "simple" features.** Even simple CRUD operations can have state machine, ownership, and boundary condition issues.

## Examples

### Example: entry-point analysis finding

```
### Mass assignment via unprotected model binding

- **Severity:** High
- **Confidence:** High
- **Category:** Implementation flaw
- **Affected files/components:** `src/Controllers/UserController.cs`, `PUT /api/users/{id}`
- **Why it matters:** The `UpdateUser` action binds directly to the `User` entity, which includes `IsAdmin` and `RoleId` properties. An attacker can send `{ "isAdmin": true }` in the request body to escalate privileges.
- **CWE / OWASP:** CWE-915 (Mass Assignment), OWASP API3:2023
- **Recommended fix:** Create a `UpdateUserDto` that includes only the fields the caller is allowed to modify. Map from the DTO to the entity explicitly. Never bind request bodies directly to domain entities.
- **Re-review required:** Yes
```

### Example: data-flow analysis finding

```
### Stored XSS via user profile bio

- **Severity:** High
- **Confidence:** Medium
- **Category:** Implementation flaw
- **Affected files/components:** `src/Features/Profile/UpdateBioHandler.cs`, `src/Pages/Profile.razor`
- **Why it matters:** The bio field is validated for length at input but stored as raw HTML. When rendered on the profile page, it uses `@((MarkupString)user.Bio)`, which renders arbitrary HTML including script tags.
- **CWE / OWASP:** CWE-79 (Cross-site Scripting), OWASP A03:2021
- **Recommended fix:** Either sanitise the bio on input using a library like HtmlSanitizer, or render it with Blazor's default encoding (remove the `MarkupString` cast). If rich text is required, sanitise on output immediately before rendering.
- **Re-review required:** Yes
```

### Example: business logic finding

```
### Coupon code reuse — no single-use enforcement

- **Severity:** Medium
- **Confidence:** High
- **Category:** Implementation flaw
- **Affected files/components:** `src/Features/Checkout/ApplyCouponHandler.cs`
- **Why it matters:** The coupon application handler checks whether the coupon exists and is not expired, but does not check whether the current user has already used it. A user can apply the same single-use coupon to multiple orders.
- **CWE / OWASP:** CWE-840 (Business Logic Error), OWASP A04:2021
- **Recommended fix:** Add a `CouponUsage` table tracking which user has used which coupon. Check for existing usage before applying. Use a unique constraint on (UserId, CouponId) to prevent race conditions.
- **Re-review required:** No
```

## Review cues

Trigger this skill when:

- Conducting manual code review for security (pre-merge or audit)
- Reviewing new endpoints, especially those accepting user input
- Reviewing authentication or authorization flow changes
- Analysing business logic for abuse potential
- Reviewing error handling or logging changes for information leakage
- A PR modifies multi-step flows (checkout, onboarding, payment)
- Automated scanners have run but manual review is needed for logic and design flaws

## Good looks like

An excellent manual review using this skill:

1. **Starts with entry-point inventory** — all ingress points are listed before any code is read in depth
2. **Traces data flows end-to-end** — untrusted data is followed from entry point through processing to every destination
3. **Checks business logic for abuse** — multi-step flows are analysed for skip, replay, and tampering attacks
4. **Validates authN/authZ at every layer** — authentication and authorization are checked at the endpoint, service, and data access layers
5. **Applies heuristics scanners miss** — race conditions, trust confusion, logic flaws, and overly permissive defaults are explicitly checked
6. **Documents findings in the standard schema** — every finding follows the `security-review-core` output format with all required fields
7. **Identifies patterns, not just instances** — a single missing `[Authorize]` leads to checking all endpoints, not just reporting one

## Common findings / likely remediations

| Finding | Severity | Remediation |
|---------|----------|-------------|
| Mass assignment — request binds directly to domain entity | High | Create a DTO with only allowed fields. Map explicitly from DTO to entity. |
| Stored XSS — user input stored raw, rendered as `MarkupString` | High | Sanitise on input with HtmlSanitizer or remove `MarkupString` cast and use default Blazor encoding. |
| TOCTOU race condition — balance check then deduction without transaction | High | Wrap check-and-act in a database transaction with appropriate isolation level, or use optimistic concurrency. |
| Multi-step flow skip — step 2 does not verify step 1 completion | Medium | Track step completion server-side. Validate prerequisite steps before processing each subsequent step. |
| No rate limiting on password reset endpoint | Medium | Add `Microsoft.AspNetCore.RateLimiting` middleware with a fixed-window policy on the reset endpoint. |
| Client-supplied value trusted for pricing | Critical | Re-fetch price server-side from the product catalog at payment time. Never trust client-submitted prices. |
| Debug endpoint accessible in production | High | Gate diagnostic endpoints behind environment checks and authentication. Remove `UseDeveloperExceptionPage()` from production configuration. |
| Insufficient audit logging for privilege escalation | Medium | Log all role changes, permission grants, and admin actions with user ID, timestamp, target resource, and action taken. |
| Open redirect via unvalidated return URL | Medium | Validate redirect URLs against an allowlist or use `Url.IsLocalUrl()` before redirecting. Never redirect to a user-supplied absolute URL. |
| Non-atomic state transition — concurrent requests create duplicate records | Medium | Use database-level unique constraints or optimistic concurrency tokens to prevent duplicate creation under concurrent requests. |
