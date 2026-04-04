---
name: "security-sources"
description: "Canonical source catalog for the security skills tree. Maps every authoritative reference to its applicable contexts, skills, and use cases."
domain: "security"
confidence: "high"
source: "manual — authored from canonical references"
---

## Context

This skill is the knowledge map for the entire security skills tree. It catalogs every authoritative source used across security skills, documents why each source is trusted, and maps each source to the project contexts and skills that reference it.

The Security Architect consults this skill to:
- Know which sources to cite when producing findings
- Determine which skills reference which sources
- Identify which sources apply to a given project type (Blazor WASM, API-only, etc.)
- Ensure recommendations are grounded in current, authoritative guidance

This is a reference skill — it does not define review workflows or patterns. For review methodology, see `security-review-core`.

## Best used for

- **All security reviews** — as the canonical knowledge map for citing sources
- **Onboarding new security skills** — to check whether a source is already cataloged or needs to be added
- **Architecture decisions** — to find authoritative guidance for a specific technology or pattern
- **Compliance mapping** — to connect findings to recognized frameworks (OWASP, NIST, CWE)
- **Source validation** — to verify that a cited reference is current and authoritative

## Primary references

All sources listed in the Patterns section below are primary references for this skill. This skill exists to catalog them.

## Patterns

### Source catalog

Each source is cataloged with its title, URL, applicability flags, and the skills that reference it. Applicability flags indicate which project contexts the source is relevant to.

**Applicability flag key:**

| Flag | Meaning |
|------|---------|
| Blazor WASM | Blazor WebAssembly client-side applications |
| Blazor Server / Web App | Blazor Server, Blazor Web App, and server-side rendered Blazor |
| ASP.NET Core APIs | Minimal APIs, Web API controllers, gRPC services |
| Browser security | Client-side browser security (CSP, CORS, COEP, sandboxing) |
| C# static analysis | CodeQL, Roslyn analyzers, SAST tooling for C# |
| Secure SDLC / CI/CD | Secure development lifecycle, pipeline security, supply chain |
| General secure code review | Applies broadly to any code review regardless of stack |

---

### Core review / Secure SDLC

Sources that define review methodology, secure development practices, and organizational security frameworks.

| # | Title | URL | Applies to | Referenced by |
|---|-------|-----|-----------|---------------|
| 1 | OWASP Secure Code Review Cheat Sheet | [cheatsheetseries.owasp.org](https://cheatsheetseries.owasp.org/cheatsheets/Secure_Code_Review_Cheat_Sheet.html) | General secure code review | `security-review-core`, `owasp-secure-code-review`, `data-access-and-validation`, `serialization-file-upload-and-deserialization` |
| 2 | OWASP Code Review Guide | [owasp.org](https://owasp.org/www-project-code-review-guide/) | General secure code review | `security-review-core`, `owasp-secure-code-review`, `data-access-and-validation` |
| 3 | NIST SP 800-218 Secure Software Development Framework (SSDF) | [csrc.nist.gov](https://csrc.nist.gov/pubs/sp/800/218/final) | Secure SDLC / CI/CD | `security-review-core`, `secrets-and-configuration`, `supply-chain-and-dependencies`, `ci-cd-ssdf-security` |
| 4 | NIST SP 800-218A Secure Software Development Practices for Generative AI and Dual-Use Foundation Models | [csrc.nist.gov](https://csrc.nist.gov/pubs/sp/800/218/a/final) | Secure SDLC / CI/CD | `ci-cd-ssdf-security` |

**Source details:**

#### 1. OWASP Secure Code Review Cheat Sheet

- **Why authoritative:** OWASP is the industry-standard open-source application security project. This cheat sheet distills the full Code Review Guide into actionable, pattern-based review guidance used globally in security audits.
- **Best used for:** Quick-reference during code reviews — provides specific patterns to look for across injection, auth, crypto, error handling, and logging. Ideal as a checklist companion during PR reviews.

#### 2. OWASP Code Review Guide

- **Why authoritative:** The comprehensive OWASP guide to secure code review methodology. Covers not just what to look for, but how to structure and execute a review. Maintained by the OWASP community with contributions from industry practitioners.
- **Best used for:** Establishing review methodology for baseline audits, training new reviewers, and understanding the "why" behind specific review patterns. More depth than the cheat sheet.

#### 3. NIST SP 800-218 Secure Software Development Framework (SSDF)

- **Why authoritative:** Published by the National Institute of Standards and Technology. SSDF is referenced by U.S. Executive Order 14028 on Improving the Nation's Cybersecurity. It defines the practices expected of software producers for federal and regulated environments.
- **Best used for:** Mapping organizational secure development practices to a recognized framework. Useful for compliance discussions, CI/CD pipeline security assessment, and supply chain integrity verification.

#### 4. NIST SP 800-218A Secure Software Development Practices for Generative AI

- **Why authoritative:** NIST extension to SSDF that addresses AI-specific risks in software development. Published as an official NIST Special Publication with public review and expert input.
- **Best used for:** Assessing security practices when generative AI is used in the development process — code generation, AI-assisted reviews, model integration. Relevant to CI/CD pipelines that incorporate AI tooling.

---

### Microsoft / .NET / Blazor

Sources covering ASP.NET Core, Blazor, and the Microsoft identity platform security guidance.

| # | Title | URL | Applies to | Referenced by |
|---|-------|-----|-----------|---------------|
| 5 | Secure ASP.NET Core Blazor WebAssembly | [learn.microsoft.com](https://learn.microsoft.com/en-us/aspnet/core/blazor/security/webassembly/?view=aspnetcore-10.0) | Blazor WASM | `dotnet-authn-authz`, `blazor-wasm-security`, `secrets-and-configuration` |
| 6 | ASP.NET Core Blazor authentication and authorization | [learn.microsoft.com](https://learn.microsoft.com/en-us/aspnet/core/blazor/security/?view=aspnetcore-10.0) | Blazor WASM, Blazor Server / Web App, ASP.NET Core APIs | `dotnet-authn-authz`, `aspnetcore-api-security`, `signalr-and-real-time-security` |
| 7 | ASP.NET Core Blazor WebAssembly additional security scenarios | [learn.microsoft.com](https://learn.microsoft.com/en-us/aspnet/core/blazor/security/webassembly/additional-scenarios?view=aspnetcore-10.0) | Blazor WASM | `dotnet-authn-authz`, `blazor-wasm-security` |
| 8 | ASP.NET Core server-side and Blazor Web App additional security scenarios | [learn.microsoft.com](https://learn.microsoft.com/en-us/aspnet/core/blazor/security/additional-scenarios?view=aspnetcore-10.0) | Blazor Server / Web App, ASP.NET Core APIs | `dotnet-authn-authz`, `aspnetcore-api-security`, `signalr-and-real-time-security` |

**Source details:**

#### 5. Secure ASP.NET Core Blazor WebAssembly

- **Why authoritative:** Official Microsoft documentation for Blazor WASM security. Written and maintained by the ASP.NET Core team. Covers the unique security model where the entire application runs in the browser sandbox.
- **Best used for:** Understanding what security guarantees Blazor WASM provides and — critically — what it does not. Essential reading before any security review of a Blazor WASM application. Covers token handling, `AuthenticationStateProvider`, and the requirement that all authorization is enforced server-side.

#### 6. ASP.NET Core Blazor authentication and authorization

- **Why authoritative:** The canonical Microsoft reference for Blazor auth across all hosting models. Covers `AuthorizeView`, `[Authorize]`, `CascadingAuthenticationState`, and the role/policy-based authorization model.
- **Best used for:** Reviewing how authentication state flows through Blazor components, verifying that `[Authorize]` attributes are correctly applied, and understanding the differences between server-side and WASM auth patterns.

#### 7. ASP.NET Core Blazor WebAssembly additional security scenarios

- **Why authoritative:** Official Microsoft guidance on advanced WASM security patterns — custom `AuthenticationStateProvider`, token refresh, attaching tokens to outgoing requests, and handling auth in standalone vs. hosted WASM apps.
- **Best used for:** Reviewing custom auth implementations in Blazor WASM. If the project has a custom `AuthenticationStateProvider` or handles token lifecycle manually, this source provides the correct patterns.

#### 8. ASP.NET Core server-side and Blazor Web App additional security scenarios

- **Why authoritative:** Official Microsoft documentation covering server-side Blazor and Blazor Web App security scenarios including circuit-level auth, SignalR hub authorization, and server-side state management security.
- **Best used for:** Reviewing server-side Blazor applications for auth state leakage across circuits, SignalR hub security, and ensuring that server-side rendering does not bypass authorization checks.

---

### Browser / WASM / Client Security

Sources covering browser security mechanisms, WebAssembly sandboxing, and client-side security headers.

| # | Title | URL | Applies to | Referenced by |
|---|-------|-----|-----------|---------------|
| 9 | WebAssembly Security Model | [webassembly.org](https://webassembly.org/docs/security/) | Blazor WASM, Browser security | `blazor-wasm-security`, `browser-security-headers` |
| 10 | OWASP Content Security Policy Cheat Sheet | [cheatsheetseries.owasp.org](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html) | Browser security, Blazor WASM, Blazor Server / Web App | `blazor-wasm-security`, `browser-security-headers` |
| 11 | MDN Cross-Origin-Embedder-Policy (COEP) | [developer.mozilla.org](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cross-Origin-Embedder-Policy) | Browser security, Blazor WASM | `blazor-wasm-security`, `browser-security-headers` |

**Source details:**

#### 9. WebAssembly Security Model

- **Why authoritative:** Published by the WebAssembly Community Group (W3C). This is the specification-level documentation of the WASM security model — memory isolation, sandboxing guarantees, and the boundaries of the WASM execution environment.
- **Best used for:** Understanding what the WASM sandbox protects against and what it does not. Critical for assessing whether a Blazor WASM application's security assumptions about client-side isolation are valid. The WASM sandbox prevents memory access outside the linear memory, but does not prevent logic bugs, data exfiltration via network, or client-side secret exposure.

#### 10. OWASP Content Security Policy Cheat Sheet

- **Why authoritative:** OWASP-maintained guidance on Content Security Policy, one of the most effective browser-side defense-in-depth controls. Covers directive syntax, common policies, and deployment strategies.
- **Best used for:** Reviewing or recommending CSP configuration for Blazor applications. Blazor WASM in particular requires specific CSP directives (`unsafe-eval` considerations, `wasm-unsafe-eval`). Use this source to verify that CSP is configured correctly and is not overly permissive.

#### 11. MDN Cross-Origin-Embedder-Policy (COEP)

- **Why authoritative:** MDN Web Docs is maintained by Mozilla and is the de facto reference for web platform APIs and HTTP headers. COEP documentation covers cross-origin isolation, which is required for `SharedArrayBuffer` and high-resolution timers — features relevant to WASM performance and security.
- **Best used for:** Reviewing cross-origin isolation configuration for Blazor WASM applications that use `SharedArrayBuffer` or need protection against Spectre-class side-channel attacks. Verify `Cross-Origin-Embedder-Policy` and `Cross-Origin-Opener-Policy` headers are set correctly.

---

### C# / Static Analysis / CWE Guidance

Sources for CodeQL, Roslyn analyzers, and CWE-specific guidance for C# codebases.

| # | Title | URL | Applies to | Referenced by |
|---|-------|-----|-----------|---------------|
| 12 | GitHub Docs: C# queries for CodeQL analysis | [docs.github.com](https://docs.github.com/en/code-security/reference/code-scanning/codeql/codeql-queries/csharp-built-in-queries) | C# static analysis | `csharp-codeql-cwe`, `serialization-file-upload-and-deserialization` |
| 13 | CodeQL for C# | [codeql.github.com](https://codeql.github.com/docs/codeql-language-guides/codeql-for-csharp/) | C# static analysis | `csharp-codeql-cwe` |
| 14 | Microsoft Learn: Use custom queries with CodeQL | [learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/repos/security/github-advanced-security-code-scanning-queries?view=azure-devops) | C# static analysis, Secure SDLC / CI/CD | `csharp-codeql-cwe`, `ci-cd-ssdf-security` |

**Source details:**

#### 12. GitHub Docs: C# queries for CodeQL analysis

- **Why authoritative:** Official GitHub documentation listing all built-in CodeQL queries for C#. Each query maps to a specific CWE and covers a known vulnerability pattern. Maintained by GitHub's CodeQL team as part of the GitHub Advanced Security product.
- **Best used for:** Checking which CWE patterns are covered by CodeQL's built-in C# queries. Use during reviews to verify whether a detected pattern would be caught by SAST, and to identify gaps where manual review is needed because no built-in query exists.

#### 13. CodeQL for C#

- **Why authoritative:** The official CodeQL language guide for C#, published by GitHub. Covers the CodeQL data model for C# — how types, methods, expressions, and data flow are modeled. Required reading for writing or understanding custom CodeQL queries.
- **Best used for:** Writing custom CodeQL queries for project-specific vulnerability patterns, understanding how CodeQL models C# constructs, and extending SAST coverage beyond built-in queries.

#### 14. Microsoft Learn: Use custom queries with CodeQL

- **Why authoritative:** Official Microsoft guidance on integrating custom CodeQL queries into Azure DevOps and GitHub Advanced Security pipelines. Covers query suites, configuration, and CI/CD integration patterns.
- **Best used for:** Reviewing CI/CD pipeline security configuration — verifying that CodeQL is enabled, custom queries are included, and scan results are enforced as quality gates. Also relevant when assessing whether the project's SAST configuration covers the CWE patterns identified during manual review.

## Anti-Patterns

- **Citing sources not in this catalog.** All security skill citations should reference sources listed here. If a new source is needed, add it to this catalog first.
- **Using outdated URLs.** Microsoft Learn URLs should target the current ASP.NET Core version (`aspnetcore-10.0` at time of writing). Verify URLs are current before citing.
- **Treating all sources as equally applicable.** Check the applicability flags — a Blazor WASM source is not relevant to an API-only project, and vice versa.
- **Omitting the "Referenced by" mapping.** When adding a new source, always document which skills reference it. Orphaned sources with no skill references indicate a gap.
- **Citing a source without explaining why it applies.** A bare URL is not a citation. State what the source says that is relevant to the finding.

## Examples

### Example: citing a source in a finding

```
### Missing Content Security Policy header

- **Severity:** Medium
- **Confidence:** High
- **Category:** Missing defense-in-depth
- **Affected files/components:** `Program.cs`, middleware pipeline
- **Why it matters:** Without a CSP header, the application is vulnerable to XSS attacks
  that inject inline scripts. CSP provides a browser-enforced allowlist of script sources.
- **CWE / OWASP:** CWE-1021, OWASP A05:2021 (Security Misconfiguration)
- **Recommended fix:** Add CSP middleware or meta tag. For Blazor WASM, use `wasm-unsafe-eval`
  instead of `unsafe-eval`. See OWASP CSP Cheat Sheet (source #10 in security-sources).
- **Re-review required:** No
```

### Example: determining applicable sources for a project

For a **Blazor WASM** project, the applicable sources are:
- Sources 1–4 (always applicable — core review and SDLC)
- Sources 5, 6, 7 (Blazor WASM auth)
- Sources 9, 10, 11 (browser/WASM security)
- Sources 12, 13, 14 (C# static analysis — if CodeQL is configured)

For an **ASP.NET Core API-only** project:
- Sources 1–4 (core review and SDLC)
- Sources 6, 8 (ASP.NET Core auth — server-side)
- Sources 12, 13, 14 (C# static analysis)

## Review cues

Trigger this skill when:

- You need to cite a source in a security finding and want to verify it is cataloged
- You are adding a new security skill and need to check which sources already cover the topic
- You are reviewing a project and need to identify which sources are applicable to the tech stack
- A source URL appears broken or outdated and needs to be verified
- You need to justify a recommendation by pointing to an authoritative reference

## Good looks like

An excellent use of this skill:

1. **Every finding cites a cataloged source** — no ad-hoc URLs or uncatalogued references
2. **Applicability flags are checked** — sources cited are relevant to the project's tech stack
3. **Source details are consulted** — the "Best used for" guidance is followed, not just the URL
4. **New sources are cataloged before use** — if a review discovers a new authoritative source, it is added here with full metadata before being cited in findings
5. **URLs are current** — Microsoft Learn URLs target the latest stable ASP.NET Core version

## Common findings / likely remediations

| Finding | Remediation |
|---------|-------------|
| Security finding cites an uncatalogued source | Add the source to this catalog with title, URL, authority justification, applicability flags, and skill references before using it |
| Source URL returns 404 or redirects to a different page | Update the URL in this catalog. For Microsoft Learn, check if the `view` parameter needs updating to the current ASP.NET Core version |
| Source applicability mismatch — Blazor WASM source cited for API-only project | Review the applicability flags and use the correct source for the project context |
| Skill references a source not listed in its "Referenced by" mapping | Update the "Referenced by" column for the source in this catalog |
| Multiple sources cover the same topic with conflicting guidance | Prefer the more specific source (e.g., Microsoft Learn for .NET-specific guidance over generic OWASP). Note the conflict and document the chosen interpretation |
