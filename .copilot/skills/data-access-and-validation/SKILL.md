---
name: "data-access-and-validation"
description: "Secure data access review for .NET — ownership checks, unsafe query patterns, server-side validation, tenant boundary enforcement, and business-logic access control."
domain: "security"
confidence: "high"
source: "manual — authored from canonical references"
---

## Context

Every data access must enforce two things independently:

1. **Authentication** — is the caller who they claim to be? (handled by middleware)
2. **Authorization** — is this authenticated caller allowed to access *this specific record*? (must be enforced at data access time, not assumed)

The second is routinely missed. An endpoint can require `[Authorize]` and still have an IDOR vulnerability if it retrieves any record by ID without confirming ownership.

## Best used for

EF Core, Dapper, ADO.NET, APIs, background jobs with data access.

## Primary references

- OWASP Secure Code Review Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Secure_Code_Review_Cheat_Sheet.html
- OWASP Code Review Guide: https://owasp.org/www-project-code-review-guide/

## Patterns

### Ownership checks — IDOR prevention

**Secure pattern:**

```csharp
var userId = _httpContextAccessor.HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
var order = await _db.Orders
    .FirstOrDefaultAsync(o => o.Id == orderId && o.UserId == userId);
if (order is null) return Results.NotFound();
return Results.Ok(order);
```

The ownership filter (`o.UserId == userId`) must be at the database query level — not applied after fetching.

### Multi-tenant boundary enforcement

In multi-tenant systems, tenant isolation must be enforced at every query:

- Every table with tenant-scoped data must include a `TenantId` (or equivalent) filter.
- Global query filters in EF Core (`HasQueryFilter`) provide a base layer but must be verified:
  - Is the global filter applied to every DbSet that needs it?
  - Can the global filter be bypassed with `.IgnoreQueryFilters()`? Flag any use of `IgnoreQueryFilters`.
  - Are admin queries that legitimately bypass tenant scoping clearly gated to admin roles?

### Parameterised raw queries

```csharp
// SAFE — parameterised
var results = await _db.Products
    .FromSqlRaw("SELECT * FROM Products WHERE Name = {0}", userInput)
    .ToListAsync();

// or
var results = await _db.Products
    .FromSqlInterpolated($"SELECT * FROM Products WHERE Name = {userInput}")
    .ToListAsync();
```

`FromSqlInterpolated` is safe (parameters extracted); `FromSqlRaw` with string interpolation is not.

### Input validation and normalisation

- Validate at the boundary — before data reaches the domain layer.
- Model validation: `[Required]`, `[StringLength]`, `[Range]`, `[RegularExpression]` via DataAnnotations or FluentValidation.
- Don't rely solely on client-side validation — it's always bypassable.
- Normalise before comparing: trim whitespace, lowercase emails, decode percent-encoding.
- Validate after normalisation, not before — normalisation can change the value.

### Server-side enforcement at data boundaries

- Computed fields (totals, prices, discounts) must be calculated server-side from trusted data sources.
- Client-supplied totals, IDs used for pricing, or role claims in the request body are all trust violations.
- Pagination parameters: validate `pageSize` has an upper bound (e.g., max 100) to prevent large data dumps.

### Business-logic access control

- Can a user perform an action that changes another user's state? (e.g., cancelling another user's order)
- Can a non-admin invoke an admin-only function by crafting a direct API call?
- Are privilege-gated actions (refund, delete, export) protected by role/policy checks at the service layer, not only UI?

## Anti-Patterns

### Missing ownership filter (IDOR)

```csharp
var order = await _db.Orders.FindAsync(orderId);
// Missing: does this order belong to the current user?
return Results.Ok(order);
```

### SQL injection via string interpolation in raw queries

```csharp
// VULNERABLE — user input in raw SQL
var results = await _db.Products
    .FromSqlRaw($"SELECT * FROM Products WHERE Name = '{userInput}'")
    .ToListAsync();
```

**String interpolation into SQL is always wrong.** Also flag: Dapper with string concatenation, ADO.NET with `SqlCommand` and string building.

### Client-supplied trust violations

- Accepting computed fields (totals, prices) from the client without server-side recalculation.
- Using client-supplied role or user ID claims from the request body instead of the authenticated identity.
- Unbounded pagination parameters allowing full data dumps.

## Examples

**Secure ownership query:**

```csharp
var userId = _httpContextAccessor.HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
var order = await _db.Orders
    .FirstOrDefaultAsync(o => o.Id == orderId && o.UserId == userId);
if (order is null) return Results.NotFound();
return Results.Ok(order);
```

**Parameterised raw SQL:**

```csharp
var results = await _db.Products
    .FromSqlInterpolated($"SELECT * FROM Products WHERE Name = {userInput}")
    .ToListAsync();
```

## Review cues

- `FindAsync(`, `Find(` — check for ownership/tenant filter.
- `FromSqlRaw(` with `$"` or `+` — SQL injection.
- `IgnoreQueryFilters()` — tenant bypass, verify admin-gated.
- `.FindFirstValue(ClaimTypes.` — confirm it's actually used to scope the query.
- Missing `[Required]`, `[StringLength]`, `[Range]` on public-facing DTOs — unvalidated input.
- `pageSize` / `take` without upper bound — data dump risk.

## Good looks like

- Every query that returns user-specific data includes an ownership filter derived from the authenticated identity.
- Tenant-scoped DbSets have global query filters; `IgnoreQueryFilters` usage is rare and admin-gated.
- All raw SQL uses parameterised methods (`FromSqlInterpolated` or `FromSqlRaw` with explicit parameters).
- DTOs have DataAnnotations or FluentValidation rules; server-side validation is never skipped.
- Computed fields are calculated server-side; client-supplied values are discarded or cross-checked.
- Pagination is bounded (e.g., `pageSize = Math.Min(requested, 100)`).

## Common findings / likely remediations

| Finding | Severity | Remediation |
|---------|----------|-------------|
| `FindAsync(id)` without ownership check | High | Add `.Where(x => x.UserId == currentUserId)` or use `FirstOrDefaultAsync` with filter |
| `FromSqlRaw` with string interpolation | Critical | Switch to `FromSqlInterpolated` or pass parameters explicitly |
| Missing `HasQueryFilter` on tenant-scoped entity | High | Add global filter in `OnModelCreating`; audit all entities |
| `IgnoreQueryFilters()` without admin role gate | High | Wrap in role/policy check |
| No server-side validation on DTO | Medium | Add DataAnnotations or FluentValidation; enforce in pipeline |
| Unbounded `pageSize` | Medium | Cap at a reasonable maximum (e.g., 100) |
| Client-supplied price/total accepted | High | Recalculate server-side from trusted data |
