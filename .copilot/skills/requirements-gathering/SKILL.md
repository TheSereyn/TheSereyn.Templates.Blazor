---
name: "requirements-gathering"
description: "Structured 10-phase requirements interview methodology — progressive-depth questioning, MoSCoW prioritisation, and comprehensive requirements.md output template. Complementary discovery tool for early-stage projects before Spec Kit specification."
---

# Requirements Gathering

## Overview

This skill defines a structured methodology for eliciting comprehensive project requirements through a conversational interview. It produces a `docs/planning/requirements.md` file that feeds into the Spec Kit specification workflow or can be used directly by a Solution Architect to design the system.

### Relationship with Spec Kit

This interview is a **complementary discovery tool**, not the primary workflow. Use it when:
- The project idea is still vague and needs structured exploration
- Multiple stakeholders need to be interviewed before formalising specifications
- The domain is complex and benefits from progressive-depth questioning

After the interview, the output (`docs/planning/requirements.md`) becomes input to Spec Kit's `/speckit.specify` phase, where requirements are formalised into executable specifications.

## Core Principles

1. **Interview, don't implement.** Ask, listen, clarify, and document — don't write code or make architecture decisions.
2. **Start broad, then drill deep.** Vision → goals → users → capabilities → data → rules → quality attributes → constraints → risks.
3. **One phase at a time.** Present questions in focused batches (3–5 questions). Wait for answers before moving on.
4. **Challenge vagueness.** Requirements like "it should be fast" or "easy to use" need concrete definitions.
5. **Summarise before advancing.** After each phase, restate what you've captured and confirm before moving on.
6. **Track progress visually.** Summarise phase completion status as you go (e.g., ✅ Phase 1 done, → Phase 2 next).

## Context Loading

At the start of every requirements session, read the project's `.github/copilot-instructions.md` to understand established coding standards, architecture preferences, and technology choices. Don't re-ask things already decided there — reference those decisions and probe for project-specific details.

---

## Interview Phases

Work through these phases in order. Skip or merge phases that aren't relevant based on earlier responses.

### Phase 1 — Project Vision and Context
- What is the project? (elevator pitch — 2–3 sentences)
- What problem does it solve, or what opportunity does it address?
- Who is sponsoring / paying for this? (internal tool, commercial product, open-source, etc.)
- Is this greenfield, a rewrite, or an extension of an existing system?
- Are there hard deadlines, budget constraints, or regulatory drivers?
- What does success look like? How will you measure it?

### Phase 2 — Users, Actors, and Personas
- Who are the primary users? (roles, personas, or actor types)
- Are there secondary users (admins, support, external integrators)?
- What are the key goals for each user type?
- Are there machine actors (other systems, scheduled jobs, webhooks)?
- Is multi-tenancy involved? If so, what's the tenant boundary?
- What authentication/identity model is expected?

### Phase 3 — Functional Requirements (Capabilities)
- What are the major features or capabilities? (headline level first)
- For each feature: triggers, inputs/outputs, happy path, error/edge cases, business rules, CRUD vs workflow vs computation
- Which features are explicitly out of scope for the initial release?
- What data does the system manage? (key entities, relationships, lifecycle)
- Import/export or migration requirements?

### Phase 4 — Domain Model and Data
- Core domain concepts / aggregates
- Key relationships and cardinalities
- Value objects or enumerations
- Data lifecycle rules (retention, archival, soft-delete)
- Invariants or business rules spanning multiple entities
- Expected data volume (order of magnitude)
- Existing data migration needs
- Audit or compliance requirements on data changes

### Phase 5 — Integrations and External Dependencies
- External systems the project integrates with
- For each: direction, protocol, auth, volume/latency, contract owner
- Third-party services (payment, email, SMS, identity provider)
- Events published for other consumers

### Phase 6 — Non-Functional Requirements (Quality Attributes)
- **Performance**: Throughput, latency targets (p50, p95, p99), peak load
- **Scalability**: Growth trajectory, horizontal scaling expectations
- **Availability**: Uptime target / SLA, acceptable downtime windows
- **Security**: Data sensitivity, compliance frameworks (GDPR, HIPAA, SOC 2, PCI)
- **Observability**: Monitoring, alerting, dashboarding requirements
- **Resilience**: Dependency failure handling, retry/fallback expectations
- **Internationalisation**: Multi-language, multi-timezone, multi-currency

### Phase 7 — UI and User Experience (if applicable)
- Is a UI needed for the initial release, or is API-first sufficient?
- Type: web app, mobile, desktop, CLI
- Key screens or workflows
- UX constraints (accessibility, branding, responsive)
- Real-time features (SignalR, live updates)

### Phase 8 — Deployment, Infrastructure, and Operations
- Where will this run? (cloud, on-prem, hybrid)
- Container-based? Kubernetes? Managed services?
- Environment strategy (dev, staging, production)
- CI/CD expectations
- Database technology preference or constraints
- Cost constraints or infrastructure budget

### Phase 9 — Constraints, Assumptions, and Risks
- Technology constraints beyond C#/.NET
- Team constraints (size, skill gaps, availability)
- Assumptions to validate
- Biggest risks to the project
- Known unknowns needing spikes or prototypes

### Phase 10 — Prioritisation and Phasing
- MVP must-haves vs deferrable features
- Dependencies between features constraining build order
- High-value/high-risk features (candidates for early prototyping)

---

## Conversation Flow Rules

1. Open with Phase 1. Briefly explain the process.
2. After each phase, summarise and ask: *"Is this accurate? Anything to add or correct?"*
3. If an answer reveals something about a later phase, note it but stay focused on the current phase.
4. Track and display phase completion status as you go.
5. If the user goes off-topic, capture the information but steer back.
6. When all phases are covered, announce you'll compile the requirements document.

---

## Output: requirements.md

Generate `docs/planning/requirements.md` with this structure:

```markdown
---
title: Project Requirements
version: 1.0
last-updated: YYYY-MM-DD
status: draft
---

# Project Requirements — [Project Name]

## 1. Project Overview
### 1.1 Vision and Purpose
### 1.2 Success Criteria
### 1.3 Scope (In / Out)
### 1.4 Constraints and Assumptions

## 2. Stakeholders and Users
### 2.1 User Roles and Personas
### 2.2 Machine Actors / External Systems
### 2.3 Authentication and Authorisation Model

## 3. Functional Requirements
### 3.1 Feature Summary (prioritised)
### 3.2 Detailed Feature Specifications
### 3.3 Domain Model Overview
### 3.4 Data Requirements

## 4. Integration Requirements
### 4.1 External System Integrations
### 4.2 Event / Messaging Requirements
### 4.3 Third-Party Services

## 5. Non-Functional Requirements
### 5.1 Performance and Scalability
### 5.2 Availability and Resilience
### 5.3 Security and Compliance
### 5.4 Observability and Operations
### 5.5 Internationalisation / Localisation

## 6. User Interface Requirements

## 7. Deployment and Infrastructure
### 7.1 Target Environment
### 7.2 CI/CD Requirements
### 7.3 Database and Persistence

## 8. Risks and Open Questions
### 8.1 Known Risks
### 8.2 Assumptions to Validate
### 8.3 Open Questions

## 9. Phasing and Prioritisation
### 9.1 MVP Scope
### 9.2 Future Phases
### 9.3 Feature Dependencies

## Appendix
### A. Glossary
### B. References
```

### Output Rules

- Only include sections with captured content. Omit empty sections.
- Each functional requirement must have an explicit acceptance criterion.
- Tag each requirement with MoSCoW priority: **Must** / **Should** / **Could** / **Won't**.
- Cross-reference `copilot-instructions.md` for established decisions.
- End with an Open Questions section for anything needing resolution.

---

## Patterns and Anti-Patterns

### Open Questions Are First-Class Artifacts

Every gap gets a numbered ID (OQ-N), context, specific question, and what it blocks:

```markdown
### OQ-1: Data Retention Policy
**Context:** The system stores user-generated content indefinitely.
**Question:** What is the required data retention period? Regulatory requirements?
**Blocks:** Database partitioning strategy, archival implementation, compliance sign-off.
```

### MoSCoW on Every Requirement

| Priority | Meaning |
|----------|---------|
| **Must** | Non-negotiable for MVP. System is useless without it. |
| **Should** | Important but MVP can launch without it. Target for v1.1. |
| **Could** | Nice to have. Include if time/budget allows. |
| **Won't** | Explicitly out of scope. Documented so it's not forgotten. |

### Separate Content Model from Navigation

Define what content *is* (fields, types, relationships) independently from how users *find* it (routes, filters, search).

### Future Scope Is Documented, Not Ignored

Items explicitly out of V1 scope go in a "Future Considerations" section.

### Anti-Patterns

- **"We'll figure it out later"** — document as an open question instead
- **Mixing requirements with solutions** — requirements say *what*, not *how*
- **Flat lists without priority** — every item at the same priority means nothing is prioritised
- **Assumptions without validation** — capture assumptions explicitly and flag for validation
