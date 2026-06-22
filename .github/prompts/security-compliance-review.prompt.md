---
agent: agent
description: "Perform a comprehensive security and compliance review of a project using the repository's security and compliance skills."
tools: ['read', 'edit', 'search', 'terminal']
---

# Security and Compliance Review

Use this prompt when you need to review a project for security posture and compliance readiness.

Your goal is to assess the project systematically, using the repository's security and compliance skills as the primary source of guidance.

## Review scope

Evaluate the project for:
- Security architecture and implementation risks
- Authentication and authorization correctness
- Secrets, configuration, and deployment safety
- Supply-chain and dependency risk
- API and browser security controls
- Data handling and validation safety
- Compliance readiness for any relevant framework

## How to approach the review

1. Read the relevant security and compliance skills from `.copilot/skills/`.
2. Review the project files that are most relevant to the requested scope.
3. Distinguish between:
   - Architectural flaws
   - Implementation flaws
   - Misconfiguration
   - Missing defence-in-depth controls
4. Produce structured findings with:
   - Summary
   - Severity
   - Confidence
   - Category
   - Affected files or areas
   - Why it matters
   - Relevant CWE or OWASP reference
   - Recommended fix
   - Re-review guidance
5. If the request is about compliance, map the findings to the relevant framework guidance from the compliance skills.

## Skills to consult

Use these skills as appropriate for the scope of the review.

### Core review skills
- `security-review-core` — review workflow, severity/confidence model, PR checklist, and required output schema
- `security-sources` — canonical reference catalog for mapping to the correct guidance

### Domain skills
- `owasp-secure-code-review` — manual review methodology, entry-point analysis, and data-flow thinking
- `dotnet-authn-authz` — ASP.NET Core auth/authz, claims, policies, token and cookie handling
- `aspnetcore-api-security` — middleware ordering, CORS, antiforgery, input validation, exception handling
- `browser-security-headers` — CSP, HSTS, COEP/CORP/COOP, framing, and cross-origin isolation
- `csharp-codeql-cwe` — CodeQL patterns, CWE mappings, manual review triggers, and false-confidence traps
- `secrets-and-configuration` — committed secrets, config hierarchy, key management, and log redaction
- `data-access-and-validation` — IDOR, ownership checks, multi-tenant boundaries, and EF Core safe query patterns
- `serialization-file-upload-and-deserialization` — BinaryFormatter, TypeNameHandling, XXE, zip slip, and path traversal
- `supply-chain-and-dependencies` — NuGet provenance, lockfiles, transitive vulns, typosquatting, and action SHA pinning
- `ci-cd-ssdf-security` — GitHub Actions permissions, pull_request_target risk, OIDC federation, and SSDF alignment
- `security-register` — project vulnerability and security finding tracker

### Compliance skills
- `compliance-gdpr`
- `compliance-hipaa`
- `compliance-iso27001`
- `compliance-pcidss`
- `compliance-soc2`

## Review output

Return a concise but actionable review report with:
1. A short summary of the current security posture
2. A list of findings grouped by severity
3. Recommended next steps
4. Any compliance gaps that should be addressed

## Guardrails

- Do not invent facts or claim guarantees that are not supported by code, config, infrastructure, or policy
- Prefer evidence-backed findings over speculation
- If the project scope is unclear, ask for the target area, architecture, or compliance framework before reviewing
