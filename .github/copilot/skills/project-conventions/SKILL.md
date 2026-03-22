---
name: "project-conventions"
description: "Core coding conventions and patterns for .NET projects — error handling, API patterns, code style, naming, async, and testing conventions"
---

# Project Conventions

## Error Handling — RFC 9457 Problem Details

All API error responses use RFC 9457 Problem Details (`application/problem+json`). No exceptions.

```json
{
  "type": "https://example.com/errors/validation-error",
  "title": "Validation failed",
  "status": 400,
  "detail": "One or more fields failed validation.",
  "instance": "/api/v1/resource"
}
```

**Error taxonomy:**
- `400` — Validation failures. Include field-level error details.
- `401` — Authentication failure. Do NOT leak details about why auth failed.
- `403` — Authorization failure. Do NOT reveal whether the resource exists.
- `404` — Resource not found. Be careful about 404 vs 403 to prevent resource enumeration.
- `409` — Conflict (e.g., duplicate creation, stale ETag).
- `500` — Unhandled server error. Log full exception server-side. Return generic message to client.

**Domain exceptions** (e.g., `NotFoundException`, `BusinessRuleViolationException`) are mapped to Problem Details at the API layer via middleware.

## API Conventions

### REPR Pattern (Request-Endpoint-Response)

- One endpoint per file
- Request/response DTOs co-located with the endpoint
- Endpoint mapping grouped by feature area

```csharp
public sealed record CreateResourceRequest(string Name, string Description);
public sealed record CreateResourceResponse(string Id);

public static class CreateResourceEndpoint
{
    public static void Map(IEndpointRouteBuilder app) =>
        app.MapPost("/api/v1/resources", HandleAsync)
           .WithName("CreateResource")
           .WithSummary("Creates a new resource")
           .Produces<CreateResourceResponse>(StatusCodes.Status201Created)
           .ProducesProblem(StatusCodes.Status400BadRequest);

    private static async Task<IResult> HandleAsync(
        CreateResourceRequest request,
        CancellationToken ct)
    {
        // Implementation
        return TypedResults.Created($"/api/v1/resources/{id}", response);
    }
}
```

### Cursor-Based Pagination

All list endpoints use cursor-based pagination:

```csharp
public sealed record PagedResponse<T>(
    IReadOnlyList<T> Items,
    string? NextCursor,
    bool HasMore);
```

### URL Structure

`/api/v1/{resource}` — URL-segment versioning.

## Code Style

### Analyzers and Build Configuration

- **StyleCop Analyzers** with standard rules enabled
- **`AnalysisLevel=latest-all`** for maximum coverage
- **`Nullable=enable`** — nullable reference types everywhere
- **`ImplicitUsings=enable`** — implicit global usings
- **`LangVersion=latest`** — latest C# features
- **File-scoped namespaces** — always

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Types, methods, properties, constants | PascalCase | `ProjectService`, `GetByIdAsync` |
| Local variables, parameters | camelCase | `projectId`, `cancellationToken` |
| Private fields | _camelCase | `_repository`, `_logger` |
| Interfaces | `I` prefix | `IProjectRepository` |
| Async methods | `Async` suffix | `GetByIdAsync`, `CreateAsync` |
| Commands | `{Verb}{Entity}Command` | `CreateProjectCommand` |
| Queries | `{Get\|List}{Entity}Query` | `ListProjectsQuery` |
| Events | `{Entity}{PastTense}Event` | `ProjectCreatedEvent` |

### Guard Clauses

Use `ArgumentNullException.ThrowIfNull` and similar guard methods:

```csharp
public void Process(Project project)
{
    ArgumentNullException.ThrowIfNull(project);
    ArgumentException.ThrowIfNullOrWhiteSpace(project.Name);
}
```

## Async Patterns

**Async all the way — zero exceptions:**

```csharp
// Correct
public async Task<Project?> GetByIdAsync(string id, CancellationToken ct)
{
    return await _repository.FindAsync(id, ct);
}

// Prohibited — sync-over-async
var result = GetByIdAsync(id, ct).Result;                    // NEVER
var result = GetByIdAsync(id, ct).Wait();                    // NEVER
var result = GetByIdAsync(id, ct).GetAwaiter().GetResult();  // NEVER
```

All async methods accept `CancellationToken`. All outbound I/O must be cancellation-aware with explicit timeouts.

## Configuration — Strongly-Typed Options

```csharp
public sealed class DatabaseOptions
{
    public const string SectionName = "Persistence";
    public string ConnectionString { get; init; } = string.Empty;
    public string DatabaseName { get; init; } = string.Empty;
}

// Bind in DI
services.Configure<DatabaseOptions>(configuration.GetSection(DatabaseOptions.SectionName));

// Inject
public sealed class MyRepository(IOptions<DatabaseOptions> options) { }
```

Config hierarchy (highest wins): Secret store > env vars > `appsettings.{Env}.json` > `appsettings.json`.
Env var nesting: double underscore `__` (e.g., `Persistence__ConnectionString`).

## Testing Conventions

**Framework:** TUnit on Microsoft Testing Platform. See the `tunit-testing` skill for full details.

**Test method naming:** `{Method}_{Scenario}_{ExpectedResult}`

**Test structure:** Arrange-Act-Assert with async TUnit assertions.

## Observability Conventions

- **OpenTelemetry** for traces, metrics, and logs (OTLP export)
- **Structured logging** — no string concatenation in log messages
- **Correlation:** `TraceId`, `SpanId`, `CorrelationId` on all log entries
- **Health checks** at `/health`, `/health/live`, `/health/ready`

## Clean Architecture Layer Rules

```
Domain       → Depends on nothing. Entities, value objects, domain events, repo interfaces.
Application  → Depends on Domain. Use cases, commands, queries, handlers, DTOs.
Infrastructure → Depends on Application + Domain. DB repos, external service clients, messaging.
API          → Depends on Application. Endpoints, DI composition root. No business logic.
```

- UI/API depend only on the Application layer
- Infrastructure depends inward
- Shared contracts only (DTOs) — never domain types across boundaries

## Anti-Patterns

- **No sync-over-async.** `.Result`, `.Wait()`, `.GetAwaiter().GetResult()` are bugs.
- **No PII in logs.** Use opaque identifiers, never emails/names/tokens.
- **No business logic in the API layer.** API is composition root + endpoint mapping only.
- **No infrastructure concerns in Domain.** Domain defines interfaces; Infrastructure implements them.
- **No `!` null-forgiving operator** without a documented comment explaining why it's safe.
