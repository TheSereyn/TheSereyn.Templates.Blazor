---
name: "requirements-gathering"
description: "Structured approach to eliciting, documenting, and tracking requirements — open questions, MoSCoW prioritisation, and traceability"
---

# Requirements Gathering

## Context

When gathering requirements for a project or feature expansion, use this pattern to ensure completeness and traceability.

## Patterns

### 1. Open Questions Are First-Class Artifacts

Every gap in requirements gets a numbered ID (OQ-N), a clear context statement, a specific question, and a list of what it blocks. Don't bury unknowns in prose.

```markdown
### OQ-1: Data Retention Policy
**Context:** The system stores user-generated content indefinitely.
**Question:** What is the required data retention period? Are there regulatory requirements (GDPR, etc.)?
**Blocks:** Database partitioning strategy, archival implementation, compliance sign-off.
```

### 2. MoSCoW Prioritisation on Every Requirement

Must / Should / Could / Won't. No requirement exists without a priority.

| Priority | Meaning |
|----------|---------|
| **Must** | Non-negotiable for MVP. System is useless without it. |
| **Should** | Important but MVP can launch without it. Target for v1.1. |
| **Could** | Nice to have. Include if time/budget allows. |
| **Won't** | Explicitly out of scope. Documented so it's not forgotten. |

### 3. Separate Content Model from Navigation

Define what content *is* (fields, types, relationships) independently from how users *find* it (routes, filters, search). They evolve at different rates.

### 4. Future Scope Is Documented, Not Ignored

Items explicitly out of V1 scope go in a "Future Considerations" section so architects don't build walls that block them.

### 5. Traceability Matrix

Every requirement should trace to the open question or decision that enables it. This makes it clear what's ready to build and what's blocked.

## Anti-Patterns

- **"We'll figure it out later"** — If it's not nailed down, it's not a requirement. Document it as an open question.
- **Mixing requirements with solutions** — Requirements say *what*, not *how*. "The site shall have syntax highlighting" is a requirement. "Use Prism.js" is an architecture decision.
- **Flat lists without priority** — Every item at the same priority means nothing is prioritised.
