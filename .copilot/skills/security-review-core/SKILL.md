---
name: "security-review-core"
description: "Meta-skill and entry point for all security reviews. Defines the review workflow, severity/confidence model, finding schema, and PR checklist."
domain: "security"
confidence: "high"
source: "manual — authored from canonical references"
---

## Context

This is the root skill in the security skills tree. Every security review — baseline audit, diff-based PR review, release assessment, or architecture review — starts here. It defines how to structure the review, how to classify findings, and what the output must look like.

Other security skills (e.g., `dotnet-authn-authz`, `blazor-wasm-security`, `data-access-and-validation`) provide domain-specific patterns. This skill provides the framework that wraps them all.

## Best used for

- **All PRs** — run the diff-based review workflow and PR checklist on every pull request
- **Baseline audits** — full codebase review to assess overall security posture
- **Release reviews** — pre-release security assessment against the severity model
- **Architecture reviews** — trust boundary analysis for new designs or major refactors
- **Any security-sensitive change** — auth, crypto, input handling, secrets, CI/CD pipeline changes

## Primary references

- [OWASP Secure Code Review Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secure_Code_Review_Cheat_Sheet.html)
- [OWASP Code Review Guide](https://owasp.org/www-project-code-review-guide/)
- [NIST SP 800-218 Secure Software Development Framework (SSDF)](https://csrc.nist.gov/pubs/sp/800/218/final)

## Patterns

### Review workflow

There are two review modes. Choose the one that matches the task:

#### 1. Baseline review (full audit)

1. **Identify trust boundaries** — map all ingress and egress points (see trust boundary analysis below)
2. **Enumerate attack surface** — list endpoints, input channels, external integrations, and data stores
3. **Walk each OWASP category** — systematically check each Top 10 category against the codebase
4. **Classify findings** — assign severity, confidence, category, and CWE/OWASP mapping using the models below
5. **Summarize posture** — overall assessment: what is strong, what is weak, what needs immediate attention

#### 2. Diff-based review (PR / changeset)

1. **Scope the change** — understand what was added, modified, or removed
2. **Check trust boundaries** — did the change introduce, move, or weaken a trust boundary?
3. **Run the PR checklist** — walk through every item in the PR review checklist below
4. **Classify findings** — use the standard finding schema
5. **Assess regression risk** — did the change weaken an existing control or remove a defense?

### Trust boundary analysis

Before reviewing code, map the system's trust boundaries:

**Ingress points** (untrusted data enters the system):
- HTTP endpoints (controllers, minimal API handlers, Razor pages)
- File uploads
- Webhooks and callback URLs
- Message queue consumers
- Background job inputs (Hangfire, Quartz, hosted services)
- SignalR hub methods
- gRPC service methods

**Egress points** (data leaves the trusted context):
- Database queries (EF Core, Dapper, raw ADO.NET)
- Outbound HTTP calls (HttpClient, Refit, RestSharp)
- File system writes
- External service calls (Azure SDK, third-party APIs)
- Email/SMS sending
- Logging output (potential data leakage)

**What to flag:**
- Untrusted data crossing into a trusted context without validation or sanitization
- Authorization decisions made client-side or missing entirely
- Serialization/deserialization at trust boundaries without type restrictions
- Secrets or tokens passed through untrusted channels

### Severity model

Use these exact tiers for every finding:

| Severity | Definition | Examples |
|----------|-----------|----------|
| **Critical** | Remote code execution, authentication bypass, significant data exposure, secret leakage | RCE via deserialization, auth middleware disabled, connection string in client bundle |
| **High** | Privilege escalation, IDOR, injection flaws, insecure deserialization | SQL injection, missing `[Authorize]` on admin endpoint, BOLA in API |
| **Medium** | Missing defense-in-depth, insecure default, CSRF risk, information disclosure | No CSP header, verbose error messages in production, missing anti-forgery token |
| **Low** | Minor hardening gap, missing security header, low-impact misconfiguration | Missing `X-Content-Type-Options`, overly permissive CORS in dev config |
| **Info** | Observation, pattern note, or suggestion with no direct risk | Code style that makes future security bugs more likely, documentation gap |

### Confidence model

| Confidence | Definition |
|-----------|-----------|
| **High** | Clear vulnerability with reproducible path, direct code evidence |
| **Medium** | Likely issue, but context or runtime configuration may affect exploitability or severity |
| **Low** | Possible concern, incomplete evidence, or highly conditional exploitation path |

### Finding categories

Separate findings into these categories in your output:

| Category | Definition | Example |
|----------|-----------|---------|
| **Architectural flaw** | Design-level issue that cannot be fixed by a single code change | No server-side authorization layer, trust boundary absent by design |
| **Implementation flaw** | Specific code that is wrong or unsafe | Raw string concatenation in SQL, hardcoded secret, missing `[Authorize]` |
| **Misconfiguration** | Incorrect settings in config files, middleware, or infrastructure | CORS allowing `*` in production, HTTPS not enforced, debug mode enabled |
| **Missing defense-in-depth** | No vulnerability today, but a missing control that would reduce blast radius | No CSP header, no rate limiting, no request size limits |

### Required output schema

Every finding **must** include all of these fields:

```
### [Summary — one-line description]

- **Severity:** Critical | High | Medium | Low | Info
- **Confidence:** High | Medium | Low
- **Category:** Architectural flaw | Implementation flaw | Misconfiguration | Missing defense-in-depth
- **Affected files/components:** `path/to/File.cs`, `ClassName`, `GET /api/resource`
- **Why it matters:** Plain-language explanation of the risk and potential impact
- **CWE / OWASP:** CWE-89, OWASP A03:2021 (Injection) — omit if not applicable
- **Recommended fix:** Concrete, actionable guidance — what to change and where
- **Re-review required:** Yes | No — whether this finding needs security re-review after fix
```

### PR review checklist

Run through **every item** on diff-based reviews. Skip only if clearly not applicable, and note the skip.

- [ ] **Authentication:** Are new endpoints protected? Has auth configuration changed?
- [ ] **Authorization:** Does every data access check ownership / tenant / role server-side?
- [ ] **Input validation:** Is user input validated, normalized, and type-checked before use?
- [ ] **Output encoding:** Is data rendered safely (HTML, JSON, SQL)?
- [ ] **Secrets:** No new secrets committed, no secrets in logs, no secrets in client-side code?
- [ ] **Dependencies:** Any new or changed packages? Known CVEs?
- [ ] **Security headers:** Any new HTTP endpoints? Are headers configured?
- [ ] **Error handling:** Do exceptions reveal stack traces or internal detail to clients?
- [ ] **Cryptography:** Any custom crypto? Is algorithm / key / IV handling correct?
- [ ] **CI/CD:** Any changes to workflows or build scripts?

## Anti-Patterns

- **Skipping categories without documenting why.** Every OWASP category and checklist item must be addressed or explicitly marked as not applicable with a reason.
- **Mixing severity tiers.** Do not call something "Medium-High" — pick one tier. If uncertain, choose the higher tier and set confidence to Medium.
- **Omitting confidence.** Every finding needs a confidence level. "I think this might be an issue" is Low confidence, not a reason to skip the finding.
- **Vague recommendations.** "Fix this" or "add validation" is not actionable. Specify what validation, where, and how.
- **Client-side-only trust.** Never treat client-side validation, client-side auth checks, or WASM-side filtering as security controls. They are UX conveniences only.
- **Reviewing only the diff in isolation.** A diff-based review must still consider the surrounding context — what the changed code interacts with, what assumptions it inherits.

## Examples

### Example finding output

```
### Unauthenticated access to admin dashboard endpoint

- **Severity:** Critical
- **Confidence:** High
- **Category:** Implementation flaw
- **Affected files/components:** `src/Controllers/AdminController.cs`, `GET /api/admin/dashboard`
- **Why it matters:** The `/api/admin/dashboard` endpoint returns sensitive system metrics (user counts, error rates, configuration state) without requiring authentication. Any network-adjacent attacker can access this data.
- **CWE / OWASP:** CWE-306 (Missing Authentication for Critical Function), OWASP A07:2021
- **Recommended fix:** Add `[Authorize(Policy = "AdminOnly")]` to the `AdminController` class or the `GetDashboard()` method. Verify the `AdminOnly` policy is registered in `Program.cs` and maps to the correct role/claim.
- **Re-review required:** Yes
```

### Example baseline summary

```
## Security Posture Summary

**Overall:** Moderate — authentication is well-implemented, but authorization is inconsistent
and several defense-in-depth controls are missing.

**Strengths:**
- JWT authentication correctly configured with short token lifetimes
- EF Core used consistently (no raw SQL detected)
- Secrets managed via Azure Key Vault, not in appsettings

**Weaknesses:**
- 3 endpoints missing `[Authorize]` attribute (see findings #1–#3)
- No CSP header configured
- CORS policy allows wildcard origin in production configuration
- No rate limiting on authentication endpoints

**Critical findings:** 1 | **High:** 3 | **Medium:** 5 | **Low:** 2 | **Info:** 4
```

## Review cues

Trigger this skill when:

- A PR is opened or updated and a security review is requested
- A new feature adds or modifies authentication, authorization, or input handling
- A baseline security audit is needed (new project, pre-release, compliance requirement)
- Architecture changes affect trust boundaries (new external integration, new API surface)
- CI/CD pipeline changes modify build, deploy, or secret management steps
- A dependency update includes security-relevant packages (auth libraries, crypto, serialization)
- Any code touches secrets, tokens, keys, or credentials

## Good looks like

An excellent security review using this skill:

1. **Starts with trust boundary mapping** — ingress and egress points are identified before any code is read
2. **Uses the correct review mode** — baseline for full audits, diff-based for PRs, never a hybrid
3. **Produces structured findings** — every finding follows the required schema exactly, no missing fields
4. **Separates finding categories** — architectural flaws, implementation flaws, misconfigurations, and defense-in-depth gaps are clearly grouped
5. **Assigns consistent severity and confidence** — uses the defined tiers, never invents new ones
6. **Completes the PR checklist** — every item addressed or explicitly marked N/A with rationale
7. **Gives actionable fixes** — recommendations reference specific files, classes, attributes, or configuration keys
8. **Flags re-review requirements** — Critical and High findings are marked for re-review; the reviewer knows what to check after the fix
9. **Summarizes posture** — baseline reviews end with a strengths/weaknesses/counts summary

## Common findings / likely remediations

| Finding | Severity | Remediation |
|---------|----------|-------------|
| Missing `[Authorize]` on controller or endpoint | High | Add `[Authorize]` attribute with appropriate policy. Prefer class-level with `[AllowAnonymous]` exceptions. |
| Hardcoded secret in source code | Critical | Move to user secrets (dev) or Azure Key Vault / environment variable (prod). Rotate the exposed secret immediately. |
| Raw SQL string concatenation | High | Use parameterized queries or EF Core LINQ. Never interpolate user input into SQL strings. |
| CORS allows wildcard origin in production | Medium | Restrict `AllowAnyOrigin()` to development. Use `WithOrigins(...)` with explicit allowed origins in production. |
| No CSP header configured | Medium | Add `Content-Security-Policy` header via middleware or `meta` tag. Start with a restrictive policy and loosen as needed. |
| Verbose error messages in production | Medium | Configure `app.UseExceptionHandler()` for production. Never return raw exception details to clients. |
| No rate limiting on auth endpoints | Medium | Add `Microsoft.AspNetCore.RateLimiting` middleware. Apply fixed-window or token-bucket policy to login/register endpoints. |
| Secrets logged in application output | High | Audit all `ILogger` calls. Never log tokens, passwords, connection strings, or API keys. Use structured logging with redaction. |
| Missing anti-forgery token on form POST | Medium | Add `[ValidateAntiForgeryToken]` or use `AutoValidateAntiforgeryToken` globally. Blazor Server handles this automatically. |
| Insecure deserialization of user input | High | Never deserialize untrusted input with `BinaryFormatter` or `Newtonsoft.Json` with `TypeNameHandling.All`. Use `System.Text.Json` with strict type handling. |
