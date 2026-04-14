---
mode: agent
description: "Compliance framework configuration. Run this to set up, revise, or deepen compliance requirements. Idempotent — safe to run at any project stage."
tools: ['read', 'edit', 'search', 'terminal']
---

# Compliance Setup

You are configuring compliance frameworks for this project. This prompt is **idempotent** — it can be run for first-time configuration, to add frameworks, or to revise existing selections.

## Step 1 — Read Current State

Read `.github/copilot-instructions.md` and check for an existing `## Compliance` section.

- If a Compliance section exists, report what is currently configured (frameworks, status, any "deferred" markers)
- If no Compliance section exists, note that this is first-time compliance configuration

Also check for `docs/planning/compliance-notes.md` — if it exists, summarise its current content.

## Step 2 — Framework Selection

Present the available compliance frameworks:

> "Which compliance frameworks apply to this project? (Select all that apply)"
>
> - **ISO 27001** — Information security management
> - **SOC 2** — Service organisation controls
> - **PCI DSS** — Payment card industry data security
> - **HIPAA** — Health information privacy (US)
> - **GDPR** — General data protection regulation (EU)
> - **Remove all** — Clear compliance configuration

If frameworks are already configured, show them as pre-selected and allow the user to add or remove.

## Step 3 — Per-Framework Configuration

For **each selected framework**, ask up to 3 targeted questions. Keep questions specific and actionable — not educational.

### ISO 27001

1. What is the certification scope? (Entire organisation, specific product/service, specific department)
2. Are you targeting a specific Statement of Applicability (SoA), or starting fresh?
3. Do you have an existing risk register or risk treatment plan?

### SOC 2

1. Which Trust Service Criteria apply? (Security is mandatory; Availability, Processing Integrity, Confidentiality, Privacy are optional)
2. Is this Type I (point-in-time) or Type II (period of time)?
3. What is the audit observation period? (e.g., 6 months, 12 months)

### PCI DSS

1. What is your SAQ type or merchant level? (SAQ A, SAQ A-EP, SAQ D, Level 1–4)
2. Does the application process, store, or transmit cardholder data directly?
3. Are you using a third-party payment processor? If so, which one?

### HIPAA

1. Is the organisation a Covered Entity or a Business Associate?
2. Does the application create, receive, maintain, or transmit electronic Protected Health Information (ePHI)?
3. Do you have an existing BAA (Business Associate Agreement) template?

### GDPR

1. What is the lawful basis for processing personal data? (Consent, Contract, Legal Obligation, Vital Interests, Public Task, Legitimate Interests)
2. Does the application process special category data (health, biometric, genetic, etc.)?
3. Is a Data Protection Impact Assessment (DPIA) required or already completed?

## Step 4 — Record Configuration

### Update `.github/copilot-instructions.md`

Under the `## Compliance` section (create it if it doesn't exist, place it after `## Security Principles`):

```markdown
## Compliance

This project operates under the following compliance frameworks:

- **<Framework>** — <one-line summary of scope from Step 3 answers>

Compliance skills provide framework-specific guidance during development. Consult the relevant skill when working on features that touch compliance-sensitive areas.
```

Ensure each selected framework's skill is listed in the `## Skills` section under `### Compliance (opt-in per project)`:

```markdown
- `compliance-<framework>` — <Framework name> compliance guidance
```

Remove any "deferred" or "not configured" markers from previous runs.

### Create/Update `docs/planning/compliance-notes.md`

Create the file if it doesn't exist. Structure:

```markdown
# Compliance Notes

## Overview

Frameworks: <comma-separated list>
Last updated: <date>
Configured via: /compliance-setup

## <Framework Name>

### Scope
<Answer to scope question>

### Key Details
<Answers to remaining questions>

### Open Items
- [ ] <Any follow-up items identified during configuration>
```

## Step 5 — Summary

Provide a summary of what was configured:

1. Which frameworks are now active
2. Which compliance skills are available
3. Where configuration is recorded (copilot-instructions.md + compliance-notes.md)
4. Any open items or follow-up actions

Remind the user:

> **This prompt is re-runnable.** As your compliance requirements evolve, run `/compliance-setup` again to update your configuration. Changes are applied to `.github/copilot-instructions.md` and `docs/planning/compliance-notes.md`.
