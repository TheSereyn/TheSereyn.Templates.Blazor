# {{PROJECT_NAME}} — Copilot Instructions

## Project Identity

- **Project:** {{PROJECT_NAME}}
- **Namespace:** {{NAMESPACE}}
- **Description:** {{DESCRIPTION}}

## Stack

| Layer | Technology |
|-------|-----------|
| **Runtime** | .NET 10, C# (latest LangVersion) |
| **API** | ASP.NET Core Minimal APIs, REPR pattern |
| **Architecture** | Clean Architecture (modular monolith or microservices) |
| **Testing** | TUnit on Microsoft Testing Platform (MTP) |
| **Code Quality** | StyleCop Analyzers + Roslyn Analyzers |
| **Observability** | OpenTelemetry (traces, metrics, logs) |

## Authoritative Standards and Sources

- **HTTP/REST:** RFC 9205 (Building Protocols with HTTP), RFC 9110 (HTTP Semantics), RFC 3986 (URI), RFC 9457 (Problem Details)
- **IETF HTTPAPI WG:** Rate limiting, idempotency-key, etc.
- **Documentation:** Prefer current Microsoft Learn docs for ASP.NET Core, .NET, Identity, Azure SDKs

## MCP Tools — Source of Truth (CRITICAL)

MCP tools are the **primary source of truth**. Training data is secondary and often outdated.

### Mandatory Pattern

Before making any assumption about .NET/C# APIs, package versions, or Azure capabilities:

1. **Search Microsoft Learn** via the MCP tool to validate your knowledge
2. **Confirm feature support** for the .NET/C# version in use
3. **Only then** propose solutions — prefer native .NET features over external packages

### When to Apply

- Any .NET/C# API question (methods, types, features, version support)
- Before suggesting external packages for functionality that might be built-in
- When uncertain about BCL or framework capabilities
- Package version verification

## .NET/C# Feature Validation (CRITICAL)

**ALWAYS search Microsoft Learn FIRST** when there's any question about .NET or C# feature support. Training data has cutoffs and may not include the latest .NET features.

## Dependency Policy

- Prefer MIT or Apache 2.0 licenses; keep dependency footprint lean
- Prefer built-in BCL and ASP.NET Core features over external libraries
- Do not add dependencies unless needed for the task
- Follow `Directory.Packages.props` for central package management when present

## Security Principles

- OAuth/OIDC for authentication; scopes/roles-based authorization
- Enforce HTTPS, strict CORS, security headers, least privilege
- Use PKCE for public clients; consider DPoP where threat model requires it
- Never commit secrets; use environment variables or secret stores
- Never log PII, tokens, or secrets; use opaque identifiers
- Threat model early and often
- Consult OWASP Top 10 (Web + API) for security guidance

## Code Quality

- **StyleCop Analyzers** for consistent code style
- **Nullable reference types** enabled; no `!` suppression without documented justification
- **File-scoped namespaces** and **implicit usings**
- **`AnalysisLevel=latest-all`** for maximum analyzer coverage
- **Async all the way** — no `.Result`/`.Wait()`/`.GetAwaiter().GetResult()`
- **`CancellationToken`** on all async methods; propagate through the full call chain

## Terminal Reliability

When executing commands in the terminal:

- Avoid PowerShell continuation prompts (`>>`) — ensure all quotes, braces, and parens are closed
- For complex multiline operations, prefer script files over terminal paste
- Keep commands idempotent and safe to re-run

## Testing — TUnit on Microsoft Testing Platform

See the `tunit-testing` skill for full details. Key points:

- **Framework:** TUnit (Apache 2.0), NOT xUnit/NUnit/MSTest
- **Platform:** Microsoft Testing Platform (MTP), NOT VSTest
- **Assertions:** Async — `await Assert.That(value).IsEqualTo(expected);`
- **Test attribute:** `[Test]` not `[Fact]` or `[TestMethod]`
- **CI flags:** `--report-trx`, `--coverage` (NOT VSTest-style `--logger "trx"`)

## Delivery Format (per task)

1. Summary of intent
2. Proposed decisions + trade-offs (2–3 options when applicable)
3. Minimal, production-ready code
4. Security notes
5. Tests (TUnit)
6. Docs/OpenAPI updates
7. Open questions
8. Deviation notice (if applicable)

## Ask-First Triggers

Copilot must clarify before coding if any of these are unclear:

- Target scope and definition of done
- Architecture boundaries (service splits, module boundaries)
- Auth provider configuration (OIDC authority, flows, scopes)
- Persistence technology and partitioning strategy
- Messaging/eventing approach
- API versioning policy
- Deployment profile and environments
- Non-functionals (latency, throughput, SLOs, cost constraints)
- Any suspected deviation from these standards

## Deviation/Escalation Policy

1. Attempt a standards-compliant solution per these instructions
2. If no compliant solution exists or a superior option conflicts, present both:
   - **Option A:** Standards-compliant (constraints, trade-offs)
   - **Option B:** Non-compliant but superior (why, benefits, risks)
3. Flag Option B as "Deviation from Instructions" — request explicit confirmation
4. Provide migration/rollback plan
5. Default: implement standards-compliant if confirmation is not given

## Micro-Checklists

- **REST:** Status codes + ProblemDetails + validation + versioning + auth + OpenAPI
- **Security:** Threats considered, inputs validated, authz enforced, secrets safe
- **Performance:** Async, cancellation, streaming/virtualization, allocation-aware
- **Observability:** Correlation IDs, structured logs, traces, KPIs
- **Tests:** Happy path + edge cases + failure + idempotency + concurrency
- **Deviation:** If applicable, present Option A vs Option B with explicit flag

## Skills

- `tunit-testing` — TUnit framework patterns, MTP CLI flags, assertion syntax
- `project-conventions` — Error handling, API patterns, code style, naming, async
- `requirements-gathering` — Structured 10-phase requirements interview and documentation
- `security-review` — OWASP-based security code review and vulnerability assessment
- `security-register` — Project vulnerability and security finding tracker
- `rfc-compliance` — HTTP/REST RFC standards checking (9205, 9110, 3986, 9457)
- `code-analyzers` — Roslyn and StyleCop analyzer setup and configuration



## Blazor UI

This project includes Blazor UI project(s) and Razor Class Libraries (RCLs) for reusable components.

### Blazor Hosting Model

The hosting model must be decided **per feature** — this is an ask-first trigger. Do not assume Server or WASM without confirming requirements.

### UI Architecture Rules

- UI depends only on the Application layer (via API for WASM, direct for Server)
- Share DTOs/contracts only between API and WASM client — never domain types
- Put reusable UI in Razor Class Libraries (RCLs)
- Minimise JavaScript interop

### Skills

- `blazor-architecture` — Hosting model guidance, multi-frontend patterns, RCL strategy, performance, state management

## Playwright

Playwright CLI ([microsoft/playwright-cli](https://github.com/microsoft/playwright-cli)) is installed globally via `@playwright/cli` with skills registered for this agent.
Use `playwright-cli --help` for available commands. Browser binaries and OS dependencies are pre-installed via `npx playwright install --with-deps`.
