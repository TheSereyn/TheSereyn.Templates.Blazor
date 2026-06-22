---
agent: agent
description: "In-container readiness gate. Run this first after the dev container starts to verify tools, configuration, and environment health. Safe to re-run at any time."
tools: ['read', 'terminal']
---

# Environment Check

Run a quick health check on the development environment. This is the first thing to run after the dev container starts. Report pass/fail for each check and summarise at the end.

## Checks

### 1 — .NET SDK

```bash
dotnet --version
```

Confirm .NET 10 (or later) is installed.

### 2 — GitHub CLI

```bash
gh auth status
```

Confirm authenticated. If not, advise the user to run `gh auth login`.

### 3 — Code Quality Files

Verify these files exist in the project root:

- `.editorconfig`
- `stylecop.json`
- `Directory.Build.props`
- `Directory.Packages.props`

### 4 — MCP Configuration

Confirm `.copilot/mcp-config.json` exists and contains server entries.

### 5 — Placeholder Resolution

Check that `README.md` and `.github/copilot-instructions.md` do **not** contain unresolved `{{` placeholders. If they do, advise the user to run `/project-setup` to configure the project.

### 6 — Git Status

```bash
git status
```

Confirm the repo is initialised and on a branch. Note any uncommitted changes.

### 7 — Container runtime (optional)

```bash
docker --version || podman --version
```

Confirm that a container runtime is available if you plan to use container-in-container workflows. If the command fails, note that the standard devcontainer setup is still available and that the runtime setup can be retried later.

### 8 — Spec Kit

```bash
specify --version
```

Confirm the `specify` CLI is available. If missing, advise re-running `bash .devcontainer/post-create.sh`.

### 9 — Security Basics

Confirm `.gitignore` includes patterns for:
- `*.pfx`, `*.key`, `*.pem` (certificates and private keys)
- `.env`, `.env.local` (environment secrets)
- `appsettings.Local.json` (local configuration overrides)

## Summary

Print a summary table:

| Check | Status |
|-------|--------|
| .NET SDK | ✅ / ❌ |
| GitHub CLI | ✅ / ❌ |
| Code Quality Files | ✅ / ❌ |
| MCP Configuration | ✅ / ❌ |
| Placeholders Resolved | ✅ / ❌ |
| Git Status | ✅ / ❌ |
| Container runtime | ✅ / ❌ |
| Spec Kit | ✅ / ❌ |
| Security Basics | ✅ / ❌ |

If all checks pass, congratulate the user — the environment is ready.

If placeholders are unresolved, direct them to run `/project-setup` next.

If any tool checks fail, provide specific remediation steps for each failure.
