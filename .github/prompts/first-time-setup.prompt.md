---
mode: agent
description: "In-container setup prompt. Run this from Copilot Chat after the dev container is ready. Configures project info, license, compliance, and security settings."
tools: ['read', 'edit', 'search', 'terminal']
---

# First-Time Setup

You are running the first-time setup for a new project created from a TheSereyn template.

## Step 1 — GitHub Authentication

Prompt the user to authenticate the GitHub CLI if they haven't already. Ask them to run this in the VS Code integrated terminal:

```bash
gh auth status
```

If it reports "You are not logged in", ask them to run:

```bash
gh auth login
```

They should follow the browser-based flow (or device code flow) to complete authentication. This is required for GitHub features, the Copilot CLI extension, and Squad's GitHub integration.

Once authenticated, verify with `gh auth status` and proceed.

## Step 2 — Check MCP Servers

Confirm that MCP configuration exists at `.copilot/mcp-config.json`. List the configured servers (Microsoft Learn, GitHub, NuGet). Note that the user-level Copilot CLI MCP config at `/home/vscode/.copilot/mcp.json` is seeded separately during container creation.

## Step 3 — Setup Verification

Verify `.editorconfig` and `stylecop.json` are present — these enforce code style and can be customised to your team preferences.

## Step 4 — Collect Project Info

Ask the user for:

1. **Project name** (e.g., `MyProject`, `Acme.OrderSystem`)
2. **Namespace root** (e.g., `Acme.OrderSystem`, `MyCompany.ProjectName`)
3. **Brief description** (one sentence describing what the project does)
4. **GitHub repo URL** (optional — e.g., `https://github.com/org/repo`)

## Step 5 — Resolve Placeholders

Update the following files, replacing placeholders:

| Placeholder | Value |
|-------------|-------|
| `{{PROJECT_NAME}}` | Project name from Step 4 |
| `{{NAMESPACE}}` | Namespace root from Step 4 |
| `{{DESCRIPTION}}` | Description from Step 4 |

Files to update:
- `.github/copilot-instructions.md`
- `.devcontainer/devcontainer.json` (container name)
- `README.md`

## Step 6 — Select License

Ask the user which license they want for the project. Offer common options:

1. **MIT** — permissive, minimal restrictions
2. **Apache 2.0** — permissive with patent grant
3. **GPL 3.0** — copyleft, derivative works must also be GPL
4. **Proprietary / None** — no open-source license

Based on their choice:
- Generate the appropriate `LICENSE` file in the project root
- Update the `## License` section in `README.md` to link to the chosen license

If the user is unsure, suggest MIT as a sensible default for open-source projects, or Proprietary if it's a commercial/internal project.

## Step 7 — Compliance Frameworks

Ask the user:

> "Does this project need to comply with any industry standards or compliance frameworks?"

Offer common examples:
- **ISO 27001** — Information security management
- **SOC 2** — Service organisation controls
- **PCI DSS** — Payment card industry data security
- **HIPAA** — Health information privacy (US)
- **GDPR** — General data protection regulation (EU)
- **None / Not sure yet**

Based on their response:
- Note the selected frameworks in `.github/copilot-instructions.md` under a new `## Compliance` section
- Append each selected compliance skill to the `## Skills` section in `.github/copilot-instructions.md`, using the format:
  `- \`compliance-<framework>\` — <Framework name> compliance guidance`
  For example: `- \`compliance-gdpr\` — GDPR compliance guidance and data protection requirements`
- Recommend the corresponding compliance skills for reference during development
- If they select any framework, create a `docs/planning/compliance-notes.md` stub with sections for each selected framework

## Step 8 — Git Initialisation

If this is a fresh clone from "Use this template":
- Verify git is initialised (`git status`)
- If the user provided a GitHub repo URL, verify or set the remote

## Step 9 — Verify Squad

Squad is installed automatically during container creation. Verify the installation:
- Report the installed version (`squad --version`)
- Run `squad doctor` to confirm everything is healthy

> **Note:** If `squad doctor` reports issues, re-run the post-create script:
> ```bash
> bash .devcontainer/post-create.sh
> ```

## Step 10 — Security Setup

- Review `.gitignore` and confirm `appsettings.*.json`, `*.pfx`, `*.key`, and `.env` files are excluded
- Run `dotnet user-secrets init` in your main project to set up local secret management
- Enable GitHub Secret Scanning on the repository (Settings → Security → Secret scanning)
- Configure branch protection on `main`: require PR reviews, require status checks to pass before merging

## Step 11 — Summary and Next Steps

Provide a summary of what was configured, then suggest:

1. **Gather requirements** — Run `/requirements-interview` in Copilot Chat with your project idea
2. **Use Squad** — Once requirements are ready, start Squad to design and implement the architecture
3. **Review skills** — The project includes skills for TUnit testing, project conventions, requirements gathering, Squad setup, security review (modular skill tree led by `security-review-core`), RFC compliance, and code analyzers

## Self-Cleanup

After completing setup, instruct the user:

> You can delete both setup prompts now — they are one-time operations:
> ```bash
> rm .github/prompts/pre-container-setup.prompt.md
> rm .github/prompts/first-time-setup.prompt.md
> ```
