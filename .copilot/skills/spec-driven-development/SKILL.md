---
name: "spec-driven-development"
description: "Spec Kit integration for Spec-Driven Development (SDD) — installation, workflow phases, constitution governance, and integration with Squad for implementation orchestration"
---

# Spec-Driven Development with Spec Kit

## Overview

This project uses **Spec Kit** (from GitHub) as its primary planning and specification workflow. Spec-Driven Development (SDD) flips the traditional process: specifications are defined first and become the source of truth that drives implementation, rather than writing code and refining later.

**Squad** serves as the implementation orchestrator — once Spec Kit produces a validated plan and task breakdown, Squad's team of specialist agents executes the implementation.

### The Handoff Model

```
Spec Kit (specify → plan → tasks)  →  Squad (implement with specialist agents)
```

- **Spec Kit owns:** requirements capture, specification refinement, constitution governance, technical planning, task decomposition
- **Squad owns:** implementation orchestration, code generation, testing, code review, security review

## Prerequisites

| Requirement | Minimum | Check |
|-------------|---------|-------|
| Python | 3.11+ | `python3 --version` |
| uv | Latest | `uv --version` |
| Git | Any | `git status` |
| GitHub Copilot | VS Code extension | Copilot Chat available |

> **Note:** `uv`, `python3`, and the `specify` CLI are pre-installed in the Dev Container. If `uv` is missing, install it via `python3 -m pip install --user uv`.

## Installation

### Initialise Spec Kit in an existing project

The `specify` CLI is pre-installed in the Dev Container (pinned to v0.5.0). Run:

```bash
specify init --here --ai copilot
```

For standalone installs outside the Dev Container:

```bash
uvx --from "git+https://github.com/github/spec-kit.git@v0.5.0" specify init --here --ai copilot
```

Key flags:
- `--here` — initialise in the current directory (do not create a new subdirectory)
- `--ai copilot` — configure GitHub Copilot as the AI agent
- `--script sh` — force POSIX shell scripts (default on Linux/macOS)
- `--no-git` — skip git init if the repo already exists

### What gets created

Spec Kit scaffolds a `.specify/` directory containing:

```
.specify/
├── agents/           # AI agent configuration (Copilot prompts)
├── scripts/          # Automation scripts (.sh and .ps1)
├── memory/           # Persistent context for the AI agent
└── ...
```

### Verification

After initialisation, these slash commands become available in Copilot Chat:

| Command | Purpose |
|---------|---------|
| `/speckit.specify` | Define and iterate on specifications |
| `/speckit.constitution` | Establish project principles and governance |
| `/speckit.clarify` | Resolve ambiguities in specifications |
| `/speckit.checklist` | Validate specification completeness |
| `/speckit.plan` | Generate a technical implementation plan |
| `/speckit.tasks` | Break the plan into actionable tasks |
| `/speckit.analyze` | Audit the plan before implementation |
| `/speckit.implement` | Execute the implementation |

## The SDD Workflow

### Phase 1 — Constitution (Governance)

Define the non-negotiable principles for your project. The constitution acts as a governance layer that constrains all subsequent specifications and plans.

```
/speckit.constitution This project follows Clean Architecture. We use TUnit for testing.
All code must pass StyleCop analysis. We follow IETF RFC 9457 for error responses.
Security review is mandatory for auth changes.
```

**Guidance for this stack:**
- Reference the standards from `.github/copilot-instructions.md` — they are already established
- Add project-specific constraints: domain rules, compliance requirements, team conventions
- The constitution is cumulative — add to it as the project evolves

### Phase 2 — Specify (Requirements)

Describe what you want to build. Focus on the **what** and **why**, not the **how**.

```
/speckit.specify Build a REST API for managing customer orders. Customers can create,
view, and cancel orders. Orders contain line items referencing a product catalogue.
Order totals are calculated server-side. The API must support pagination and filtering.
```

**Tips:**
- Start broad, then refine with `/speckit.clarify`
- Use `/speckit.checklist` to verify completeness
- Don't specify technology choices here — that comes in the plan phase
- If you've already run a `/requirements-interview`, reference the `docs/planning/requirements.md` output as input

### Phase 3 — Plan (Technical Design)

Provide your technology stack and architecture preferences.

```
/speckit.plan Use ASP.NET Core Minimal APIs with Clean Architecture. PostgreSQL via
EF Core for persistence. OpenTelemetry for observability. Follow the project conventions
and security skills defined in .copilot/skills/.
```

**For this stack, always include:**
- .NET 10 / C# latest
- ASP.NET Core Minimal APIs (or Blazor for UI projects)
- TUnit for testing
- StyleCop + Roslyn analyzers
- OpenTelemetry

### Phase 4 — Tasks (Decomposition)

Break the plan into implementable units:

```
/speckit.tasks
```

Optionally validate first:

```
/speckit.analyze
```

### Phase 5 — Implement (Handoff to Squad)

Once Spec Kit has produced a validated task list, hand off to Squad for implementation:

```
/speckit.implement
```

Or, for more control, use Squad directly:

```
@squad Implement the tasks from the Spec Kit plan. Follow the specification and
constitution. Use the project skills for testing, security, and code conventions.
```

Squad will assign tasks to specialist agents (architect, implementer, tester, security reviewer) and orchestrate the build.

## Integration with Existing Skills

Spec Kit's constitution and specification phases benefit from the project's established skills:

| Skill | How it integrates with SDD |
|-------|---------------------------|
| `project-conventions` | Reference in constitution for coding standards |
| `tunit-testing` | Reference in plan phase for test strategy |
| `security-review-core` | Security review during and after implementation |
| `rfc-compliance` | API design constraints for the plan phase |
| `requirements-gathering` | Complementary discovery tool for early-stage exploration |
| `squad-setup` | Squad manages implementation after planning |

## Constitution Patterns

### Enterprise / Compliance Projects

```
/speckit.constitution This project must comply with [GDPR|SOC2|PCI DSS].
All data access must be audited. PII must be encrypted at rest and in transit.
Security review is required for all auth and data-handling changes.
Refer to the compliance skills in .copilot/skills/ for framework-specific rules.
```

### API-First Projects

```
/speckit.constitution All APIs follow IETF RFC 9457 for error responses.
Endpoints use RFC 9110 HTTP semantics. URIs follow RFC 3986.
Rate limiting is mandatory on all public endpoints.
OpenTelemetry traces every request.
```

### Formal Requirements Projects

```
/speckit.constitution Every feature must trace back to a numbered requirement.
MoSCoW prioritisation is mandatory. Open questions are tracked as first-class
artifacts. The requirements-interview output (docs/planning/requirements.md) is
the authoritative requirements source.
```

## When to Use Requirements Interview vs Spec Kit

| Scenario | Tool | Rationale |
|----------|------|-----------|
| **New project, blank slate** | Spec Kit (`/speckit.specify`) | SDD workflow captures requirements as executable specs from the start |
| **Early discovery, vague idea** | Requirements Interview (`/requirements-interview`) | Structured 10-phase interview helps crystallise unclear concepts before specifying |
| **Complex domain, many stakeholders** | Requirements Interview → Spec Kit | Interview first to capture breadth, then feed `requirements.md` into Spec Kit for formal specification |
| **Adding a feature to existing project** | Spec Kit (`/speckit.specify`) | Feature-level specs with constitution governance |
| **Compliance-heavy project** | Requirements Interview → Spec Kit | Interview captures compliance context; constitution enforces it |

## Anti-Patterns

- **Skipping the constitution** — Without governance, specifications drift from project standards
- **Specifying technology in the specify phase** — Technology choices belong in the plan phase
- **Implementing without `/speckit.tasks`** — Task decomposition prevents monolithic, hard-to-review changes
- **Bypassing Squad for implementation** — Squad's specialist agents (security, testing, architecture) catch issues a single agent misses
- **Duplicating copilot-instructions in the constitution** — Reference the existing instructions, don't repeat them
- **Using Spec Kit for trivial changes** — Bug fixes and small refactors don't need full SDD ceremony

## File Locations

| Artifact | Path | Owned by |
|----------|------|----------|
| Spec Kit configuration | `.specify/` | Spec Kit CLI |
| Constitution | `.specify/` (managed by Spec Kit) | Project team via `/speckit.constitution` |
| Specifications | `.specify/` (managed by Spec Kit) | Project team via `/speckit.specify` |
| Requirements (if interview used) | `docs/planning/requirements.md` | Requirements interview |
| Copilot instructions | `.github/copilot-instructions.md` | Template (base) |
| Skills | `.copilot/skills/` | Template (base + overlays) |

## Reference

- **Spec Kit repository:** https://github.com/github/spec-kit
- **Documentation:** https://github.github.com/spec-kit/
- **Quick start:** https://github.github.com/spec-kit/quickstart.html
- **Installation:** https://github.github.com/spec-kit/installation.html
