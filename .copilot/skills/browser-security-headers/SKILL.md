---
name: "browser-security-headers"
description: "HTTP security headers review for browser-delivered applications. Covers CSP, X-Frame-Options, HSTS, COEP/CORP/COOP, and cross-origin isolation for Blazor, MVC/Razor, and WASM frontends."
domain: "security"
confidence: "high"
source: "manual — authored from canonical references"
---

## Context

HTTP security headers are the first line of browser-enforced defence. They control what the browser is allowed to do with the page's content, scripts, and resources. Missing or misconfigured headers are a common finding in production ASP.NET Core apps. This skill covers the headers relevant to Blazor Server, Blazor WebAssembly, MVC/Razor Pages, and static frontend hosting layers.

## Best used for

- Blazor, MVC/Razor, frontend hosting layers, browser-delivered apps
- Pre-deployment header review
- CSP configuration and tuning

## Primary references

- OWASP Content Security Policy Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html
- MDN Cross-Origin-Embedder-Policy (COEP): https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cross-Origin-Embedder-Policy
- WebAssembly Security Model: https://webassembly.org/docs/security/

## Patterns

### Content-Security-Policy (CSP)

The most impactful and most complex security header. Controls which sources can be loaded for scripts, styles, images, fonts, etc.

**For Blazor Server / Blazor Web App:**

```http
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; connect-src 'self' wss://yourdomain.com; img-src 'self' data:; frame-ancestors 'none'
```

- `wss://` needed for SignalR/Blazor Server websocket connection.
- `'unsafe-inline'` in style-src often needed for Blazor's CSS isolation mechanism.

**For Blazor WebAssembly:**

```http
Content-Security-Policy: default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; connect-src 'self' https://api.yourdomain.com; img-src 'self' data:; frame-ancestors 'none'
```

- `'wasm-unsafe-eval'` required for WASM module compilation in the browser.
- `frame-ancestors 'none'` prevents clickjacking.

### X-Frame-Options

- `DENY` — cannot be embedded in any frame. Recommended for most apps.
- `SAMEORIGIN` — only frames from the same origin allowed.
- Superseded by CSP `frame-ancestors`, but `X-Frame-Options` provides legacy browser coverage.
- Both can coexist; CSP takes precedence in modern browsers.

### HTTP Strict Transport Security (HSTS)

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

- `max-age=31536000` = 1 year (recommended minimum for preload).
- `includeSubDomains` — only if ALL subdomains support HTTPS.
- `preload` — submits domain to browser preload lists; irreversible until removal requested.
- Development: never set HSTS (local HTTP will break).

### Cross-Origin headers (COEP / CORP / COOP)

These three headers together enable cross-origin isolation, required for `SharedArrayBuffer` and high-resolution timers (relevant for Blazor WASM performance features).

**COEP (Cross-Origin-Embedder-Policy):**

```http
Cross-Origin-Embedder-Policy: require-corp
```

Prevents page from loading cross-origin resources unless those resources explicitly grant permission via CORP header.

**CORP (Cross-Origin-Resource-Policy):**

```http
Cross-Origin-Resource-Policy: same-origin
```

Tells browsers this resource can only be loaded by same-origin documents.

**COOP (Cross-Origin-Opener-Policy):**

```http
Cross-Origin-Opener-Policy: same-origin
```

Prevents cross-origin popups from retaining a reference to the window object.

When all three are set together, the page is "cross-origin isolated" and can use `SharedArrayBuffer`. This is required for some Blazor WASM threading scenarios.

**Review note:** COEP `require-corp` will break embedding of third-party resources (fonts, CDN scripts) that don't send CORP headers. Only enable if the app controls all embedded resources or if cross-origin isolation is explicitly needed.

### X-Content-Type-Options

```http
X-Content-Type-Options: nosniff
```

- Prevents MIME-type sniffing — browser must use the declared `Content-Type`.
- Prevents script execution from a response that declares `text/plain` but contains JS.
- Lowest-cost, highest-value header — should always be set.

### Referrer-Policy

```http
Referrer-Policy: strict-origin-when-cross-origin
```

- Controls how much of the URL is sent in the `Referer` header on navigation.
- `strict-origin-when-cross-origin`: sends only origin (no path/query) for cross-origin, full URL for same-origin.
- `no-referrer`: never send referrer — more private but breaks analytics.

### Setting headers in ASP.NET Core

```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Append("X-Content-Type-Options", "nosniff");
    context.Response.Headers.Append("X-Frame-Options", "DENY");
    context.Response.Headers.Append("Referrer-Policy", "strict-origin-when-cross-origin");
    context.Response.Headers.Append("Content-Security-Policy", "...");
    await next();
});
```

Or use `NWebsec.AspNetCore.Middleware` / `NetEscapades.AspNetCore.SecurityHeaders` package for a structured API.

## Anti-Patterns

- No CSP configured (missing entirely).
- CSP with `default-src *` — provides no protection.
- `script-src 'unsafe-eval'` without WASM justification.
- HSTS with `max-age=0` (disables HSTS — exposes to downgrade attacks).
- COEP set without CORP on all owned resources (will break resource loading silently).
- `X-Frame-Options` absent on apps that render HTML.
- `X-Content-Type-Options` absent — trivial to add, no reason to omit.

## Examples

### Minimal secure header set for a Blazor Server app

```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Append("X-Content-Type-Options", "nosniff");
    context.Response.Headers.Append("X-Frame-Options", "DENY");
    context.Response.Headers.Append("Referrer-Policy", "strict-origin-when-cross-origin");
    context.Response.Headers.Append("Content-Security-Policy",
        "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; " +
        "connect-src 'self' wss://yourdomain.com; img-src 'self' data:; frame-ancestors 'none'");
    await next();
});
```

### HSTS configuration in ASP.NET Core

```csharp
if (!app.Environment.IsDevelopment())
{
    app.UseHsts();
}
app.UseHttpsRedirection();
```

## Review cues

- Search for `Content-Security-Policy` in middleware, `web.config`, or reverse proxy config — present or absent?
- If CSP is present, check for `unsafe-eval` or `*` wildcards in directives.
- Search for `X-Content-Type-Options` and `X-Frame-Options` — should be on all HTML-serving responses.
- Check HSTS: is it gated to non-development environments? Is `max-age` meaningful (not `0`)?
- For Blazor WASM apps: is `wasm-unsafe-eval` used instead of `unsafe-eval`?
- For apps needing cross-origin isolation: are all three COEP/CORP/COOP headers set consistently?
- Check `report-uri` or `report-to` on CSP — is violation reporting configured?

## Good looks like

- CSP configured with explicit directives per resource type (no `default-src *`).
- `X-Content-Type-Options: nosniff` set on all responses.
- `X-Frame-Options: DENY` (or `SAMEORIGIN` with justification) on HTML responses.
- HSTS with `max-age` ≥ 31536000, gated to production only.
- `Referrer-Policy` set to `strict-origin-when-cross-origin` or stricter.
- CSP violation reporting configured via `report-to` directive.
- Cross-origin headers (COEP/CORP/COOP) set only when cross-origin isolation is explicitly needed and all resources are controlled.

## Common findings / likely remediations

| Finding | Severity | Remediation |
|---------|----------|-------------|
| No CSP header configured | High | Add CSP with explicit directives for all resource types |
| `script-src 'unsafe-eval'` without WASM need | High | Remove `unsafe-eval`; use `wasm-unsafe-eval` only for WASM |
| CSP with `default-src *` | High | Replace with explicit `'self'` and per-directive allowlists |
| Missing `X-Content-Type-Options` | Medium | Add `X-Content-Type-Options: nosniff` to all responses |
| Missing `X-Frame-Options` | Medium | Add `X-Frame-Options: DENY` on HTML-serving endpoints |
| HSTS `max-age=0` or very short | Medium | Set `max-age=31536000` with `includeSubDomains` |
| HSTS set in development | Low | Gate HSTS behind `!IsDevelopment()` check |
| Missing `Referrer-Policy` | Low | Add `Referrer-Policy: strict-origin-when-cross-origin` |
| COEP without CORP on owned resources | Medium | Add CORP headers to all owned resources or remove COEP |
| CSP violation reporting not configured | Low | Add `report-to` directive for visibility into violations |
