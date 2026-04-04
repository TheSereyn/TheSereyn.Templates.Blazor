# Squad Setup

How to install and initialise [Squad](https://github.com/bradygaster/squad) in a new project.

> **Squad is alpha software** — installation steps may change between releases.
> Before following this guide, fetch the current README from `https://github.com/bradygaster/squad`
> (use the `fetch_webpage` tool or Microsoft Learn MCP) and verify the steps below still match.
> If they differ, follow the upstream README and flag the discrepancy to the user.

## Prerequisites

| Requirement | Minimum | Check |
|-------------|---------|-------|
| Node.js | 22.5.0+ | `node --version` |
| Git | Any | `git status` (must be inside a git repo) |
| GitHub CLI | Any | `gh auth status` (must be authenticated) |

## Installation

### Option A — Global install (recommended for regular use)

```bash
npm install -g @bradygaster/squad-cli
```

### Option B — One-shot via npx (no global install)

```bash
npx @bradygaster/squad-cli
```

After global install, verify:

```bash
squad --version
```

## Initialise Squad in the project

```bash
squad init
```

This scaffolds the `.squad/` directory with:

- `team.md` — team roster
- `routing.md` — message routing rules
- `decisions.md` — shared decision log
- `agents/` — individual agent charters and history
- `skills/` — team-learned skills (grows over time)

## Verify setup

```bash
squad doctor
```

This checks prerequisites, file structure, and GitHub connectivity.

## Usage in VS Code

Open Copilot Chat and select the Squad agent (`@squad`). Start with:

```
I'm starting a new project. Set up the team.
Here's what I'm building: <describe your project>
```

Squad will propose a team of specialists. Confirm to begin.

## Upgrading

```bash
npm install -g @bradygaster/squad-cli@latest
squad upgrade
```

`squad upgrade` updates Squad-owned files to the latest version without touching your team state.

## Key commands

| Command | Purpose |
|---------|---------|
| `squad init` | Scaffold Squad in current directory (idempotent) |
| `squad doctor` | Check setup and diagnose issues |
| `squad upgrade` | Update Squad files to latest |
| `squad status` | Show active squad and configuration |
| `squad copilot` | Add/remove the Copilot coding agent |

## Reference

- **Repository**: https://github.com/bradygaster/squad
- **Documentation**: https://bradygaster.github.io/squad/
- **npm package**: `@bradygaster/squad-cli`
