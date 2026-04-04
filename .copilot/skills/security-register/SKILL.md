---
name: "security-register"
description: "Maintain a project-level security register for tracking vulnerabilities, security findings, and their remediation status. Use when recording, updating, or reviewing security findings."
---

# Security Register

## Purpose

The security register is a living document at `docs/security/register.md` that tracks all security findings — whether from code reviews, dependency scans, penetration tests, or external reports.

## Register Structure

Initialise the register with this structure:

```markdown
---
title: Security Register
last-updated: YYYY-MM-DD
---

# Security Register

## Open Findings

| ID | Severity | Category | Title | Found | Status | Owner |
|----|----------|----------|-------|-------|--------|-------|

## Mitigated Findings

| ID | Severity | Category | Title | Found | Resolved | Resolution |
|----|----------|----------|-------|-------|----------|------------|

## Accepted Risks

| ID | Severity | Category | Title | Accepted By | Justification | Review Date |
|----|----------|----------|-------|-------------|---------------|-------------|
```

## Finding Entry Template

When adding a new finding:

```markdown
### SEC-NNN: [Title]

- **Severity:** Critical | High | Medium | Low | Informational
- **Category:** OWASP reference (e.g., A01 Broken Access Control)
- **Status:** Open | In Progress | Mitigated | Accepted | Won't Fix | Duplicate | False Positive
- **Found:** YYYY-MM-DD
- **Source:** Code review | Dependency scan | Pen test | Bug report | etc.
- **Location:** File path or component
- **Description:** What the vulnerability is
- **Impact:** What an attacker could achieve
- **Recommendation:** How to fix it
- **CVE:** If applicable
- **Owner:** Who is responsible for remediation
- **Target Date:** When remediation should be complete
```

## Severity Definitions

| Severity | Definition | Response Time |
|----------|-----------|---------------|
| **Critical** | Exploitable vulnerability with severe business impact. Data breach, RCE, auth bypass. | Immediate — stop other work |
| **High** | Significant vulnerability requiring prompt attention. Privilege escalation, data exposure. | Within current sprint |
| **Medium** | Vulnerability with limited impact or requiring specific conditions. | Next sprint |
| **Low** | Minor issue or defense-in-depth improvement. | Backlog |
| **Informational** | Observation or improvement recommendation. No exploitable vulnerability. | Backlog |

## Workflow

1. **Record** — Add finding with full details when discovered
2. **Triage** — Assign severity, owner, and target date
3. **Remediate** — Fix the issue, reference the finding ID in commit messages
4. **Verify** — Confirm the fix addresses the finding
5. **Close** — Move to Mitigated Findings table with resolution details

For accepted risks, document the business justification and set a review date to reassess.

## Integration Points

- Reference finding IDs (SEC-NNN) in commit messages and PR descriptions
- Review the register during sprint planning for outstanding items
- Cross-reference with the `security-review-core` skill for systematic code review
- Update after dependency scans (`dotnet list package --vulnerable`)

## CVSS Scoring

Use the Common Vulnerability Scoring System (CVSS) to provide objective, repeatable severity scores for findings.

### CVSS 3.1
CVSS 3.1 is widely adopted and should be included in finding entries when available. Add the score, qualitative rating, and vector string:

```
**CVSS 3.1:** 7.5 (High) AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N
```

| Score Range | Qualitative Rating |
|-------------|-------------------|
| 0.0 | None |
| 0.1–3.9 | Low |
| 4.0–6.9 | Medium |
| 7.0–8.9 | High |
| 9.0–10.0 | Critical |

Calculator: https://www.first.org/cvss/calculator/3.1

### CVSS 4.0
CVSS 4.0 (released November 2023) improves granularity, particularly for OT/IoT environments, and adds supplemental metrics (e.g., Automatable, Recovery, Value Density, Provider Urgency). Adopt CVSS 4.0 when your tooling and processes support it. Both versions may coexist during transition — include whichever version your scanning tools produce and note the version used.

Calculator: https://www.first.org/cvss/calculator/4.0

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [FIRST CVSS v3.1 Specification](https://www.first.org/cvss/v3.1/specification-document)
- [FIRST CVSS v4.0 Specification](https://www.first.org/cvss/v4.0/specification-document)
