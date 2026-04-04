---
name: "security-review"
description: "DEPRECATED — superseded by the modular security skill tree. Use security-review-core as the entry point instead."
---

# ⚠️ Deprecated Skill

This skill has been superseded by the modular security skill tree introduced in the `feature/security-skills-tree` branch.

**Use `security-review-core` instead** — it provides the same review workflow, severity model, and PR checklist, plus structured output schema, trust-boundary analysis, and links to 10 domain-specific sub-skills.

## Migration

| Old | New |
|-----|-----|
| `security-review` (entry point) | `security-review-core` (entry point) |
| OWASP Top 10 checklist | `owasp-secure-code-review` |
| .NET auth checks | `dotnet-authn-authz` |
| API security | `aspnetcore-api-security` |
| All other domains | See `## Skills` in `copilot-instructions.md` |

This file is retained for backwards compatibility with projects that reference it directly.
