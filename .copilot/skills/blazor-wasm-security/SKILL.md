---
name: "blazor-wasm-security"
description: "WASM trust model, client-side authorization boundaries, token storage risks, JS interop trust boundary, MSAL token flow review, wwwroot secrets exposure, and server-side re-authorization requirements for Blazor WebAssembly applications"
domain: "security"
confidence: "high"
source: "OWASP, Microsoft Blazor WASM security docs, WebAssembly security model"
---

# Blazor WebAssembly Security

## Context

Blazor WebAssembly runs .NET code in the browser sandbox. The entire application — DLLs, configuration, and static assets under `wwwroot/` — is downloaded to and inspectable by the client. **The WASM client is completely untrusted.** Any authorization, validation, or secret handling that exists only client-side is bypassable.

## Patterns

### 1. Server-Side Authorization Is the Only Enforcement Boundary

Client-side `[Authorize]` attributes and route guards are **UX conveniences**, not security controls. The server API must independently authenticate and authorize every request.

**Vulnerable:**
```csharp
// WASM component — the only authorization check
[Authorize(Roles = "Admin")]
@page "/admin/users"
<h3>User Management</h3>
@* Fetches data without server-side role check *@
@code {
    protected override async Task OnInitializedAsync()
    {
        users = await Http.GetFromJsonAsync<List<User>>("/api/users");
    }
}
```

**Safe:**
```csharp
// Server API — enforces authorization independently
[Authorize(Roles = "Admin")]
[HttpGet("/api/users")]
public IActionResult GetUsers() => Ok(_userService.GetAll());
```
```csharp
// WASM component — client guard is UX only
[Authorize(Roles = "Admin")]
@page "/admin/users"
@code {
    protected override async Task OnInitializedAsync()
    {
        // Server rejects if token lacks Admin role
        users = await Http.GetFromJsonAsync<List<User>>("/api/users");
    }
}
```

### 2. Never Store Secrets in Client-Side Artifacts

Everything under `wwwroot/` ships to the browser. `appsettings.json` in a WASM project is publicly readable.

**Vulnerable:**
```json
// wwwroot/appsettings.json — shipped to browser
{
  "ApiKey": "sk-live-abc123secret",
  "ConnectionStrings": { "Db": "Server=prod;Password=hunter2;" }
}
```

**Safe:**
```json
// wwwroot/appsettings.json — public configuration only
{
  "ApiBaseUrl": "https://api.example.com",
  "Auth": { "Authority": "https://login.example.com", "ClientId": "wasm-app" }
}
```

### 3. Token Storage and Handling

MSAL.js stores tokens in `sessionStorage` by default. `localStorage` is higher risk because tokens survive page close and persist through XSS exploitation.

**Vulnerable:**
```javascript
// Storing token in localStorage — persists across sessions, XSS theft window is indefinite
localStorage.setItem("access_token", token);
```

**Safe — handle AccessTokenNotAvailable correctly:**
```csharp
var tokenResult = await TokenProvider.RequestAccessToken();
if (tokenResult.TryGetToken(out var token))
{
    request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token.Value);
}
else
{
    // Redirect to login — never suppress this failure silently
    Navigation.NavigateToLogin(tokenResult.InteractiveRequestUrl);
}
```

### 4. AuthorizationMessageHandler Scope

Configure the handler to attach tokens only to intended API endpoints. An overly broad base URL sends tokens to unintended hosts.

**Vulnerable:**
```csharp
// Sends the access token to ANY URL — tokens leak to third-party APIs
builder.Services.AddHttpClient("Api")
    .AddHttpMessageHandler(sp => sp.GetRequiredService<AuthorizationMessageHandler>()
        .ConfigureHandler(authorizedUrls: new[] { "https://" }));
```

**Safe:**
```csharp
builder.Services.AddHttpClient("Api",
    client => client.BaseAddress = new Uri("https://api.example.com"))
    .AddHttpMessageHandler(sp => sp.GetRequiredService<AuthorizationMessageHandler>()
        .ConfigureHandler(authorizedUrls: new[] { "https://api.example.com" }));
```

### 5. JS Interop Trust Boundary

Each `IJSRuntime.InvokeAsync` call crosses from managed .NET into untrusted JavaScript. Do not pass secrets or credentials through interop, and avoid invoking third-party JS that could expand the XSS surface.

**Vulnerable:**
```csharp
// Passing access token to JS — now exposed to any XSS in the page
await JSRuntime.InvokeVoidAsync("sendBeacon", accessToken, payload);
```

**Safe:**
```csharp
// Keep token server-side; JS only handles presentation
await JSRuntime.InvokeVoidAsync("showNotification", "Upload complete");
```

### 6. Content Security Policy for WASM

Blazor WASM currently requires `wasm-unsafe-eval` in CSP. Minimize additional unsafe directives.

**Vulnerable:**
```
Content-Security-Policy: default-src * 'unsafe-inline' 'unsafe-eval';
```

**Safe:**
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; connect-src 'self' https://api.example.com;
```

## Examples

| Scenario | Approach |
|----------|----------|
| Admin panel in WASM | `[Authorize]` on component for UX; API enforces role on every endpoint |
| Storing user preferences | Fetch from server API on demand; cache in-memory only during session |
| Calling third-party API | Proxy through server API; never expose third-party API keys in WASM |
| Token refresh | Use MSAL's built-in refresh; handle `AccessTokenNotAvailable` with redirect |

## Anti-Patterns

- Authorization logic implemented only in WASM, not backed by server API checks
- Secrets hardcoded in `wwwroot/appsettings.json` (shipped to browser)
- Token stored in `localStorage` without justification (XSS persistent theft)
- `AuthorizationMessageHandler` configured with overly broad URL scope
- `AuthenticationStateProvider` claims trusted without server-side token validation per request
- Sensitive data passed through JS interop to untrusted third-party scripts
- Missing or overly permissive Content Security Policy headers
- Suppressing `AccessTokenNotAvailable` instead of redirecting to login

## Best used for

Blazor WebAssembly, browser-delivered .NET frontends, WASM-hosted SPAs calling secured APIs.

## Primary references

- Secure ASP.NET Core Blazor WebAssembly: https://learn.microsoft.com/en-us/aspnet/core/blazor/security/webassembly/?view=aspnetcore-10.0
- ASP.NET Core Blazor WebAssembly additional security scenarios: https://learn.microsoft.com/en-us/aspnet/core/blazor/security/webassembly/additional-scenarios?view=aspnetcore-10.0
- WebAssembly Security Model: https://webassembly.org/docs/security/
- OWASP Content Security Policy Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html
- MDN Cross-Origin-Embedder-Policy (COEP): https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cross-Origin-Embedder-Policy

## Review cues

- [ ] Every API endpoint called from WASM has server-side `[Authorize]` with appropriate policy
- [ ] `wwwroot/appsettings.json` contains no secrets, connection strings, or API keys
- [ ] Token storage uses `sessionStorage` (MSAL default); `localStorage` usage is justified and documented
- [ ] `AccessTokenNotAvailable` results in a login redirect, never a silent swallow
- [ ] `AuthorizationMessageHandler` authorized URLs are scoped to the exact API base URI
- [ ] JS interop calls do not pass tokens, credentials, or PII to JavaScript
- [ ] Content Security Policy is present and does not include `unsafe-eval` (only `wasm-unsafe-eval`)
- [ ] No client-supplied identifiers (userId, roles) are trusted by the server API without validation
- [ ] Third-party scripts loaded via interop are integrity-checked (SRI) or self-hosted

## Good looks like

- All authorization enforced at the API layer; WASM components use `[Authorize]` only for UX gating
- `wwwroot/` contains only public configuration (authority, client ID, base URLs)
- MSAL handles token lifecycle; `AuthorizationMessageHandler` targets only the app's own API
- CSP header is restrictive with `wasm-unsafe-eval` as the only concession
- JS interop is limited to presentation concerns; no secrets cross the boundary
- `AuthenticationStateProvider` drives UI state; server independently validates the bearer token

## Common findings / likely remediations

| Finding | Remediation |
|---------|-------------|
| Authorization only in WASM component | Add `[Authorize(Policy = "...")]` to the corresponding API endpoint |
| Secret in `wwwroot/appsettings.json` | Move to server-side configuration; proxy calls through the API |
| Token in `localStorage` | Switch to MSAL default (`sessionStorage`); add CSP to limit XSS surface |
| No server-side auth on API endpoint | Add `[Authorize]` and validate claims in the endpoint handler |
| Broad `AuthorizationMessageHandler` URL | Restrict `authorizedUrls` to the exact API base address |
| `AccessTokenNotAvailable` suppressed | Add `Navigation.NavigateToLogin(tokenResult.InteractiveRequestUrl)` |
| Missing CSP header | Add CSP with `default-src 'self'` and `script-src 'self' 'wasm-unsafe-eval'` |
| Sensitive data through JS interop | Refactor to keep sensitive data in .NET; pass only display values to JS |
