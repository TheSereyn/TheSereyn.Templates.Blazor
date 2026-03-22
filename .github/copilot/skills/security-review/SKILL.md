---
name: "security-review"
description: "OWASP-based security code review checklist for .NET applications. Use when reviewing code for security vulnerabilities, conducting pre-merge security checks, or assessing threat exposure."
---

# Security Code Review

## When to Use

Invoke this skill when:
- Reviewing a PR or code change for security issues
- Assessing a module or feature for threat exposure
- Conducting a periodic security audit
- Before deploying to production

## Review Framework

Work through each OWASP category systematically against the code under review. Not every category applies to every change — skip categories that are clearly irrelevant, but document why you skipped them.

### OWASP Top 10 (Web) Checklist

| # | Category | What to Check |
|---|----------|---------------|
| A01 | **Broken Access Control** | Authorization on every endpoint, deny-by-default, CORS policy, directory traversal, IDOR |
| A02 | **Cryptographic Failures** | Data classification, encryption at rest/transit, strong algorithms, no hardcoded keys |
| A03 | **Injection** | Parameterized queries, input validation, output encoding, command injection vectors |
| A04 | **Insecure Design** | Threat modeling done, abuse cases considered, rate limiting, business logic flaws |
| A05 | **Security Misconfiguration** | Default credentials removed, error messages sanitized, unnecessary features disabled, security headers |
| A06 | **Vulnerable Components** | Dependencies up to date, known CVEs checked, minimal dependency footprint |
| A07 | **Identification & Auth Failures** | Strong password policy, MFA support, session management, credential storage |
| A08 | **Software & Data Integrity Failures** | CI/CD pipeline integrity, deserialization safety, dependency verification |
| A09 | **Security Logging & Monitoring** | Audit events logged, no PII/secrets in logs, alerting on suspicious activity |
| A10 | **SSRF** | URL validation, allowlists for outbound requests, no user-controlled URLs to internal services |

### OWASP API Security Top 10 (2023) Checklist

| # | Category | What to Check |
|---|----------|---------------|
| API1 | **Broken Object-Level Authorization** | Authorization per object, not just per endpoint |
| API2 | **Broken Authentication** | Token validation, key rotation, auth flow security |
| API3 | **Broken Object Property-Level Authorization** | Mass assignment prevention, response filtering |
| API4 | **Unrestricted Resource Consumption** | Rate limiting, pagination limits, payload size limits |
| API5 | **Broken Function-Level Authorization** | Admin vs user endpoint separation, role checks |
| API6 | **Unrestricted Access to Sensitive Business Flows** | Bot protection, abuse rate detection |
| API7 | **Server-Side Request Forgery** | URL allowlisting, internal network protection |
| API8 | **Security Misconfiguration** | HTTPS enforced, CORS, security headers, detailed errors disabled |
| API9 | **Improper Inventory Management** | API versioning, deprecated endpoints removed, documentation current |
| API10 | **Unsafe Consumption of APIs** | Third-party API responses validated, timeouts set, TLS verified |

## .NET-Specific Checks

- **Anti-forgery tokens** on state-changing operations
- **`[Authorize]` or equivalent** on all non-public endpoints
- **`TypedResults`** used to ensure correct response types at compile time
- **No `dynamic` or untyped deserialization** of user input
- **`CancellationToken`** propagated (prevents resource exhaustion)
- **`IDataProtectionProvider`** for any app-level encryption
- **Connection strings and secrets** in environment variables or secret stores, never in config files

## Output Format

For each finding, document:

```markdown
### [SEVERITY] Finding Title
- **Category:** OWASP Web A03 / API1 / etc.
- **Location:** File path and line range
- **Description:** What the vulnerability is
- **Impact:** What an attacker could achieve
- **Recommendation:** How to fix it
- **Reference:** Link to relevant OWASP cheat sheet or guidance
```

Severity levels: **Critical**, **High**, **Medium**, **Low**, **Informational**

## Authoritative References

- [OWASP Top 10 (Web)](https://owasp.org/www-project-top-ten/)
- [OWASP API Security Top 10 (2023)](https://owasp.org/www-project-api-security/)
- [OWASP .NET Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/DotNet_Security_Cheat_Sheet.html)
- [OWASP REST Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [OWASP ASVS (Application Security Verification Standard)](https://owasp.org/www-project-application-security-verification-standard/)

> **Note:** Always verify guidance against the current versions at the links above. OWASP updates these resources regularly.
