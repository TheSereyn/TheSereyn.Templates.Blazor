---
mode: agent
description: "One-shot setup prompt for new projects created from this template. Verifies environment, collects project info, resolves placeholders, and provides next steps."
tools: ['read', 'edit', 'search', 'terminal']
---

# First-Time Setup

You are running the first-time setup for a new project created from a TheSereyn template.

## Step 1 — Verify Environment

Check that the DevContainer is running with all required tools:

```bash
dotnet --info
node --version
gh --version
az --version
```

Report the status of each tool. If any are missing, warn the user but continue.

## Step 2 — Check MCP Servers

Confirm that MCP configuration exists at `.copilot/mcp-config.json`. List the configured servers (Microsoft Learn, GitHub, Azure).

## Step 3 — Collect Project Info

Ask the user for:

1. **Project name** (e.g., `MyProject`, `Acme.OrderSystem`)
2. **Namespace root** (e.g., `Acme.OrderSystem`, `MyCompany.ProjectName`)
3. **Brief description** (one sentence describing what the project does)
4. **GitHub repo URL** (optional — e.g., `https://github.com/org/repo`)

## Step 4 — Resolve Placeholders

Update the following files, replacing placeholders:

| Placeholder | Value |
|-------------|-------|
| `{{PROJECT_NAME}}` | Project name from Step 3 |
| `{{NAMESPACE}}` | Namespace root from Step 3 |
| `{{DESCRIPTION}}` | Description from Step 3 |

Files to update:
- `.github/copilot-instructions.md`
- `.devcontainer/devcontainer.json` (container name)
- `README.md`

## Step 5 — Git Initialisation

If this is a fresh clone from "Use this template":
- Verify git is initialised (`git status`)
- If the user provided a GitHub repo URL, verify or set the remote

## Step 6 — Install or Verify Squad

Check if Squad is already installed by looking for its agent file (typically `.github/agents/squad.agent.md` or `.squad/team.md`).

**If Squad is found:**
- Report the installed version (`squad --version` if available)
- Run `squad doctor` to confirm everything is healthy

**If Squad is NOT found (expected for new repos):**
- Read the `squad-setup` skill for installation and initialisation steps
- Before proceeding, fetch the current Squad README from `https://github.com/bradygaster/squad` and verify the skill's steps are still accurate (Squad is alpha software and the process may change)
- Walk the user through installation and `squad init`
- Run `squad doctor` to verify setup

## Step 7 — Summary and Next Steps

Provide a summary of what was configured, then suggest:

1. **Start with the Business Analyst** — Use `@Business Analyst` in Copilot Chat with your project idea to generate requirements
2. **Use Squad** — Once requirements are ready, start Squad to design and implement the architecture
3. **Review skills** — The project includes skills for TUnit testing, project conventions, requirements gathering, and Playwright CLI

## Self-Cleanup

After completing setup, instruct the user:

> You can delete this setup prompt now — it's a one-time operation:
> ```
> rm .github/prompts/first-time-setup.prompt.md
> ```
