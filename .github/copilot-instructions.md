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

- **Authentication:** OAuth/OIDC with PKCE for public clients; consider DPoP where elevated token binding is required. Use `[Authorize]` attributes and policies — never rely on client-side checks alone.
- **CORS:** Never use `AllowAnyOrigin()` in production. Enumerate allowed origins explicitly. `AllowAnyOrigin` with `AllowCredentials` is rejected by browsers and is a CORS misconfiguration.
- **Security headers:** Apply all of the following in middleware or reverse proxy:
  - `Strict-Transport-Security` (HSTS) — enforce HTTPS
  - `Content-Security-Policy` — restrict resource sources
  - `X-Content-Type-Options: nosniff` — prevent MIME sniffing
  - `X-Frame-Options: DENY` or CSP `frame-ancestors` — prevent clickjacking
  - `Referrer-Policy: strict-origin-when-cross-origin`
  - `Permissions-Policy` — restrict browser features
  - For Blazor WASM: enable COEP/CORP/COOP for cross-origin isolation where SharedArrayBuffer is used
- **Input validation:** Validate all inputs at the server boundary. Use model binding validation attributes (`[Required]`, `[MaxLength]`, `[RegularExpression]`). Do not trust client-supplied identifiers without ownership checks.
- **Output encoding:** HTML-encode all user-supplied content rendered in HTML. Use `HttpUtility.HtmlEncode` or Razor's automatic encoding. Never inject raw user input into HTML, SQL, or shell commands.
- **CSRF protection:** Enable ASP.NET Core antiforgery for state-changing form submissions. APIs using JWT bearer authentication are inherently CSRF-resistant (no cookies) — but cookie-authenticated APIs must enforce antiforgery.
- **Rate limiting:** Apply `RateLimiter` middleware for all public endpoints. Use `AddRateLimiter` / `RequireRateLimiting` in ASP.NET Core 7+.
- **Secrets:** Never commit secrets. Use `dotnet user-secrets` for development. Use Key Vault / environment variables in production. Ensure `appsettings.*.json` files with secrets are in `.gitignore`.
- **Logging:** Never log PII, tokens, secrets, or full request bodies. Use opaque identifiers (IDs, not names/emails). Set `EnableSensitiveDataLogging(false)` in EF Core production config.
- **Threat modelling:** Apply STRIDE (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege) early in design. Reference: [Microsoft Threat Modeling Tool](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool).
- **Dependency security:** Run `dotnet list package --vulnerable` regularly. Prefer `Directory.Packages.props` for central version management.
- **Security review:** Consult `security-review-core` for the systematic review workflow. Consult OWASP Top 10 (2021) and API Security Top 10 (2023).

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

## Observability — OpenTelemetry

This stack uses **OpenTelemetry** for traces, metrics, and logs. Always use the .NET 8+ unified builder pattern — do **not** use the legacy `AddOpenTelemetryTracing` / `AddOpenTelemetryMetrics` (pre-.NET 8) overloads.

### Standard Setup Pattern

```csharp
builder.Services.AddOpenTelemetry()
    .ConfigureResource(r => r.AddService(
        serviceName: builder.Environment.ApplicationName,
        serviceVersion: Assembly.GetExecutingAssembly()
                                .GetCustomAttribute<AssemblyInformationalVersionAttribute>()
                                ?.InformationalVersion ?? "unknown"))
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddOtlpExporter())
    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddRuntimeInstrumentation()
        .AddOtlpExporter())
    .WithLogging(logging => logging
        .AddOtlpExporter());
```

### Key conventions

- **OTLP exporter** (`OpenTelemetry.Exporter.OpenTelemetryProtocol`) is the standard egress — configure via `OTEL_EXPORTER_OTLP_ENDPOINT` environment variable, not hardcoded in code.
- **Service name** comes from `IHostEnvironment.ApplicationName` or `OTEL_SERVICE_NAME` env var — not magic strings.
- **Custom activities:** use `ActivitySource` registered via `.AddSource("YourSource.Name")` in `WithTracing()`.
- **Custom metrics:** use `Meter` registered via `.AddMeter("YourMeter.Name")` in `WithMetrics()`.
- **Never call** `AddOpenTelemetryTracing()` or `AddOpenTelemetryMetrics()` — these are legacy and removed in .NET 8+.
- Validate OTel setup is present before adding instrumentation packages (MCP search first).

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
- Security-sensitive changes (auth, secrets, middleware order, CORS)
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

## Development Workflow — Spec-Driven Development

This project uses **Spec Kit** for spec-driven development (SDD) and **Squad** for implementation orchestration.

### The Standard Flow

1. **Define governance** — `/speckit.constitution` establishes project principles and constraints
2. **Specify requirements** — `/speckit.specify` captures what to build and why
3. **Refine and validate** — `/speckit.clarify` and `/speckit.checklist` resolve ambiguities
4. **Plan implementation** — `/speckit.plan` produces a technical design aligned with this stack
5. **Decompose into tasks** — `/speckit.tasks` creates actionable work items
6. **Implement with Squad** — Squad's specialist agents execute the plan

See the `spec-driven-development` skill for full details, constitution patterns, and integration guidance.

### When to Use What

| Need | Tool |
|------|------|
| Define and iterate on specifications | Spec Kit (`/speckit.specify`) |
| Early-stage discovery for vague ideas | Requirements Interview (`/requirements-interview`) |
| Implementation orchestration | Squad (`@squad`) |
| Small bug fixes / refactors | Direct coding (no ceremony needed) |

## Skills

### Development Workflow
- `spec-driven-development` — Spec Kit integration, SDD workflow phases, constitution governance, and Squad handoff patterns
- `requirements-gathering` — Structured 10-phase requirements interview for early-stage discovery (complementary to Spec Kit)
- `squad-setup` — Squad installation, `squad init`, team design, and implementation orchestration

### Code Quality and Conventions
- `tunit-testing` — TUnit framework patterns, MTP CLI flags, assertion syntax
- `project-conventions` — Error handling, API patterns, code style, naming, async
- `rfc-compliance` — HTTP/REST RFC standards checking (9205, 9110, 3986, 9457)
- `code-analyzers` — Roslyn and StyleCop analyzer setup and configuration

### Security (entry point: `security-review-core`)
- `security-review-core` — Security review workflow, severity/confidence model, PR checklist, and required output schema
- `security-sources` — Canonical reference catalog (OWASP, NIST, Microsoft Learn, CodeQL) mapped to each security domain
- `owasp-secure-code-review` — Manual review methodology, entry-point and data-flow analysis
- `dotnet-authn-authz` — ASP.NET Core auth/authz, claims, policies, token and cookie review
- `aspnetcore-api-security` — Middleware ordering, CORS, antiforgery, input validation, exception handling
- `browser-security-headers` — CSP, HSTS, COEP/CORP/COOP, cross-origin isolation
- `csharp-codeql-cwe` — CodeQL patterns, CWE mappings, manual review triggers
- `secrets-and-configuration` — Committed secrets, config hierarchy, key management, log redaction
- `data-access-and-validation` — IDOR, ownership checks, EF Core safe query patterns, multi-tenant boundaries
- `serialization-file-upload-and-deserialization` — BinaryFormatter, TypeNameHandling, XXE, zip slip, path traversal
- `supply-chain-and-dependencies` — NuGet provenance, lockfiles, transitive vulns, typosquatting, action SHA pinning
- `ci-cd-ssdf-security` — GitHub Actions permissions, pull_request_target risk, OIDC federation, SSDF alignment
- `security-register` — Project vulnerability and security finding tracker

### Compliance (opt-in per project)
- `compliance-gdpr` — GDPR compliance guidance and data protection requirements
- `compliance-hipaa` — HIPAA compliance guidance
- `compliance-iso27001` — ISO 27001 information security management
- `compliance-pcidss` — PCI DSS payment card security
- `compliance-soc2` — SOC 2 service organisation controls

## Prompts

| Prompt | Description |
|--------|-------------|
| `first-time-setup` | In-container setup — project identity, license, compliance, security configuration |
| `pre-container-setup` | Host-level prerequisites checklist before opening the dev container |
| `verify-setup` | Lightweight environment health check — re-runnable at any time |
| `requirements-interview` | Structured discovery interview for early-stage or complex-domain projects |
| `hire-security-architect` | Opt-in prompt to add a Security Architect agent to your Squad team |



- `blazor-architecture` — Hosting model guidance, multi-frontend patterns, RCL strategy, performance, state management
- `blazor-wasm-security` — WASM trust model, client-side auth boundaries, token storage risks, JS interop boundary
- `signalr-and-real-time-security` — Hub per-invocation auth, token query-string exposure, circuit identity staleness

## Blazor UI

This project includes Blazor UI project(s) and Razor Class Libraries (RCLs) for reusable components.

### Blazor Hosting Model

The hosting model must be decided **per feature** — this is an ask-first trigger. Do not assume Server or WASM without confirming requirements.

### UI Architecture Rules

- UI depends only on the Application layer (via API for WASM, direct for Server)
- Share DTOs/contracts only between API and WASM client — never domain types
- Put reusable UI in Razor Class Libraries (RCLs)
- Minimise JavaScript interop

## Playwright

Playwright CLI ([microsoft/playwright-cli](https://github.com/microsoft/playwright-cli)) is installed globally via `@playwright/cli` with skills registered for this agent.
Use `playwright-cli --help` for available commands. Browser binaries and OS dependencies are pre-installed via `npx playwright install --with-deps`.
