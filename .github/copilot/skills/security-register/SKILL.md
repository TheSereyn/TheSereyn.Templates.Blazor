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

- **Severity:** Critical | High | Medium | Low
- **Category:** OWASP reference (e.g., A01 Broken Access Control)
- **Status:** Open | In Progress | Mitigated | Accepted
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
- Cross-reference with the `security-review` skill for systematic code review
- Update after dependency scans (`dotnet list package --vulnerable`)

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
