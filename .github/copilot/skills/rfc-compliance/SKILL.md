---
name: "rfc-compliance"
description: "Check HTTP/REST API code against RFC standards (9205, 9110, 3986, 9457). Use when reviewing API endpoints, error handling, or HTTP semantics for standards conformance."
---

# RFC Compliance Checking

## Applicable Standards

| RFC | Topic | Key Requirements |
|-----|-------|-----------------|
| [RFC 9205](https://www.rfc-editor.org/rfc/rfc9205.html) | Building Protocols with HTTP | Use HTTP correctly as an application protocol |
| [RFC 9110](https://www.rfc-editor.org/rfc/rfc9110.html) | HTTP Semantics | Method semantics, status codes, headers, content negotiation |
| [RFC 3986](https://www.rfc-editor.org/rfc/rfc3986.html) | URI Syntax | URI structure, encoding, resolution |
| [RFC 9457](https://www.rfc-editor.org/rfc/rfc9457.html) | Problem Details | Structured error responses for HTTP APIs |
| [IETF HTTPAPI WG](https://datatracker.ietf.org/group/httpapi/documents/) | Emerging standards | Rate limiting headers, idempotency-key, etc. |

## HTTP Method Semantics (RFC 9110)

| Method | Safe | Idempotent | Expected Usage |
|--------|------|------------|----------------|
| GET | Yes | Yes | Retrieve resource. No side effects. No request body. |
| HEAD | Yes | Yes | Same as GET but no response body. |
| POST | No | No | Create resource or trigger action. |
| PUT | No | Yes | Replace resource entirely. Client provides full representation. |
| PATCH | No | No | Partial update. Use with appropriate media type. |
| DELETE | No | Yes | Remove resource. Subsequent calls return 404 or 204. |
| OPTIONS | Yes | Yes | Describe communication options (CORS preflight). |

### Common violations
- Using POST for idempotent operations (should be PUT)
- Using GET with side effects (should be POST)
- Using PUT for partial updates (should be PATCH)
- Using DELETE with a request body

## Status Code Compliance (RFC 9110)

### Success codes
- **200 OK** — Successful GET, PUT, PATCH, DELETE with body
- **201 Created** — Successful POST creating a resource. Must include `Location` header.
- **202 Accepted** — Request accepted for async processing. Should include status endpoint.
- **204 No Content** — Successful DELETE or PUT/PATCH with no response body

### Client error codes
- **400 Bad Request** — Malformed syntax or invalid request parameters
- **401 Unauthorized** — Missing or invalid authentication
- **403 Forbidden** — Authenticated but not authorized. Do not reveal resource existence.
- **404 Not Found** — Resource does not exist. Be careful about 404 vs 403 (resource enumeration).
- **405 Method Not Allowed** — Must include `Allow` header listing valid methods
- **409 Conflict** — State conflict (duplicate creation, stale ETag, concurrent modification)
- **422 Unprocessable Content** — Syntactically valid but semantically invalid
- **429 Too Many Requests** — Rate limited. Should include `Retry-After` header.

### Common violations
- Using 200 for everything (including creation)
- Missing `Location` header on 201
- Missing `Allow` header on 405
- Using 500 for client errors
- Returning 200 with an error in the body

## Problem Details Compliance (RFC 9457)

All error responses must use `application/problem+json`:

```json
{
  "type": "https://example.com/errors/not-found",
  "title": "Resource not found",
  "status": 404,
  "detail": "No resource with ID 'abc-123' exists.",
  "instance": "/api/v1/resources/abc-123"
}
```

### Required fields
- **`type`** — URI reference identifying the error type. Use `about:blank` if no specific type.
- **`status`** — HTTP status code (integer)

### Recommended fields
- **`title`** — Short human-readable summary. Should NOT change between occurrences.
- **`detail`** — Human-readable explanation specific to this occurrence.
- **`instance`** — URI reference identifying the specific occurrence.

### Common violations
- Returning plain text or custom JSON for errors instead of Problem Details
- Missing `type` field (defaults to `about:blank` but should be explicit)
- Using `title` for instance-specific information (that goes in `detail`)
- Not setting `Content-Type: application/problem+json`

### ASP.NET Core implementation
Use `TypedResults.Problem()` and `TypedResults.ValidationProblem()` which produce RFC 9457-compliant responses natively. Configure `ProblemDetailsOptions` in DI for global consistency.

## URI Design (RFC 3986)

- Use lowercase paths: `/api/v1/resources` not `/Api/V1/Resources`
- Use hyphens for multi-word segments: `/api/v1/order-items` not `/api/v1/orderItems`
- Collection endpoints are plural: `/api/v1/resources`
- Instance endpoints include identifier: `/api/v1/resources/{id}`
- Avoid trailing slashes — treat `/resources` and `/resources/` as equivalent
- Avoid file extensions in URIs — use `Accept` header for content negotiation
- Percent-encode special characters per RFC 3986

## IETF HTTPAPI Working Group (Emerging)

Be aware of these drafts — not yet RFC but increasingly adopted:

- **Rate Limit Headers** — `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`
- **Idempotency-Key** — Client-provided key for safe retries of non-idempotent operations
- **Link Hints** — API discoverability via link relations

Check current status at: https://datatracker.ietf.org/group/httpapi/documents/

## Review Output

When checking code for RFC compliance, produce a structured report:

```markdown
### [PASS/FAIL] Check description
- **RFC:** RFC NNNN, Section X.Y
- **Location:** File and line
- **Finding:** What was found
- **Expected:** What the RFC requires
- **Fix:** How to make it compliant
```
