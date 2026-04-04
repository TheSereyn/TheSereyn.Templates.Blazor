---
name: "aspnetcore-api-security"
description: "ASP.NET Core API security review — middleware ordering, CORS, antiforgery, input validation, exception handling, and secure defaults for Minimal APIs and MVC controllers."
domain: "security"
confidence: "high"
source: "manual — authored from canonical references"
---

## Context

ASP.NET Core APIs are secured through layered middleware, attribute-based policies, and framework conventions. Security defects most often arise from middleware misordering, overly permissive CORS, missing input validation, and information disclosure through unguarded exception detail. This skill encodes the review patterns for Minimal APIs, MVC controllers, and Blazor service backends running on ASP.NET Core 7+.

## Best used for

- ASP.NET Core APIs, MVC, Minimal APIs, service backends
- Middleware configuration review
- New API endpoint security review

## Primary references

- ASP.NET Core Blazor authentication and authorization: https://learn.microsoft.com/en-us/aspnet/core/blazor/security/?view=aspnetcore-10.0
- ASP.NET Core server-side and Blazor Web App additional security scenarios: https://learn.microsoft.com/en-us/aspnet/core/blazor/security/additional-scenarios?view=aspnetcore-10.0

## Patterns

### Middleware order matters

The security of ASP.NET Core pipelines depends on middleware order. Review `Program.cs` for this canonical secure order:

```csharp
app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseCors();           // CORS before auth
app.UseAuthentication();
app.UseAuthorization();
app.UseAntiforgery();    // if using Blazor/Razor
app.MapControllers();    // after all security middleware
```

Any auth or validation middleware placed *after* endpoint mapping may not execute. This is a common misconfiguration.

### CORS review

- `AllowAnyOrigin()` is almost always wrong for APIs that handle authentication or sensitive data.
- `AllowAnyOrigin().AllowCredentials()` is rejected by browsers (CORS spec) but indicates a developer misunderstanding.
- Correct pattern: explicit origin allowlist using `WithOrigins("https://yourdomain.com")`.
- `AllowAnyHeader()` and `AllowAnyMethod()` are lower-risk but should be scoped for production.
- Pre-flight caching: `SetPreflightMaxAge()` reduces OPTIONS request overhead.
- Per-endpoint CORS overrides: `[EnableCors]` / `[DisableCors]` — ensure they don't accidentally open endpoints.

### Antiforgery (CSRF) protection

- Required for: state-changing form posts in MVC/Razor Pages, Blazor Server forms.
- NOT required for: JSON APIs with proper CORS and `Authorization: Bearer` headers (bearer token acts as CSRF proof).
- Blazor: `AddAntiforgery()` + `UseAntiforgery()` required for Blazor Web App form endpoints.
- Verify antiforgery service is registered AND middleware added AND token validated.
- `[ValidateAntiForgeryToken]` on controller actions — missing on PATCH/DELETE/POST?

### Input validation and model binding

- `[ApiController]` attribute enables automatic model validation and 400 responses.
- Without `[ApiController]`: manual `ModelState.IsValid` check required on every action.
- Minimal APIs: use `TypedResults` and validate before processing.
- Bind sources: `[FromBody]`, `[FromQuery]`, `[FromRoute]`, `[FromHeader]` — explicit binding prevents mass assignment.
- Request size limits: `[RequestSizeLimit]` attribute per-endpoint, or configure globally via Kestrel `MaxRequestBodySize` — missing limits enable resource exhaustion.
- Rate limiting: `app.UseRateLimiter()` (.NET 7+) — missing enables brute force and DoS.

### Exception handling and information disclosure

- `app.UseDeveloperExceptionPage()` must ONLY be used in `Development` environment.
- Production: `app.UseExceptionHandler("/error")` or `UseExceptionHandler(handler => ...)`.
- ProblemDetails: `services.AddProblemDetails()` — configure to strip internal detail in non-development.
- Stack traces in responses = High severity information disclosure.
- Connection string errors, file paths, internal hostnames in error responses = High severity.
- Custom exception middleware must not re-expose exception details.

### Security headers via middleware

For ASP.NET Core APIs without a browser-facing frontend, minimal headers needed:

- `X-Content-Type-Options: nosniff` — prevent MIME sniffing.
- `X-Frame-Options: DENY` — prevent clickjacking (if any HTML responses).
- `Strict-Transport-Security` — HSTS for HTTPS enforcement.

For browser-facing apps (Blazor, Razor Pages), see `browser-security-headers` skill.

### TypedResults for type safety

- `TypedResults` (not `Results`) provides compile-time type checking of response types.
- Prevents accidentally returning wrong types or forgetting to return a response.
- Enables OpenAPI schema generation accuracy.

## Anti-Patterns

- Middleware placed after `MapControllers()` / `MapEndpoints()` — security middleware will not execute for those endpoints.
- `AllowAnyOrigin()` combined with credential-bearing APIs.
- `UseDeveloperExceptionPage()` called unconditionally (not gated by environment check).
- Missing `[ApiController]` on controllers that assume automatic validation.
- No rate limiting and no request size limits on public-facing APIs.
- Hardcoded secrets in `Program.cs` or `appsettings.json` committed to source control.

## Examples

### Secure defaults checklist for new APIs

- [ ] `[Authorize]` or `RequireAuthorization()` on all non-public endpoints
- [ ] `AllowAnyOrigin()` absent from CORS config
- [ ] `UseDeveloperExceptionPage()` gated to Development only
- [ ] Request size limits configured
- [ ] Rate limiting configured (or explicitly deferred to infrastructure)
- [ ] `AddProblemDetails()` with sanitised error detail
- [ ] No hardcoded secrets in startup config

## Review cues

- Open `Program.cs` and trace middleware order top-to-bottom — any security middleware after endpoint mapping?
- Search for `AllowAnyOrigin` — is it paired with credential-bearing auth?
- Search for `UseDeveloperExceptionPage` — is it gated behind `if (app.Environment.IsDevelopment())`?
- Search for `[ValidateAntiForgeryToken]` on POST/PUT/PATCH/DELETE controller actions.
- Check for `[ApiController]` attribute on all API controllers.
- Search for `UseRateLimiter` and `RequestSizeLimit` — present or absent?

## Good looks like

- Middleware in canonical order with security middleware before endpoint mapping.
- CORS configured with explicit `WithOrigins()` allowlist and scoped methods/headers.
- `[ApiController]` on all API controllers with explicit bind sources.
- `UseExceptionHandler` in production with `AddProblemDetails()` configured to sanitise output.
- Rate limiting and request size limits in place.
- Antiforgery configured for Blazor/Razor form endpoints, not applied to pure JSON APIs.

## Common findings / likely remediations

| Finding | Severity | Remediation |
|---------|----------|-------------|
| Middleware after `MapControllers()` | High | Move security middleware above endpoint mapping |
| `AllowAnyOrigin()` on auth API | High | Replace with explicit `WithOrigins()` allowlist |
| `UseDeveloperExceptionPage()` unconditional | High | Gate behind `IsDevelopment()` check |
| Stack traces in production error responses | High | Use `AddProblemDetails()` with sanitised detail |
| Missing `[ApiController]` attribute | Medium | Add attribute to enable automatic validation |
| No rate limiting configured | Medium | Add `UseRateLimiter()` with appropriate policies |
| No request size limits | Medium | Add `[RequestSizeLimit]` attribute or configure Kestrel `MaxRequestBodySize` |
| `AllowAnyHeader()` / `AllowAnyMethod()` | Low | Scope to required headers and methods for production |
