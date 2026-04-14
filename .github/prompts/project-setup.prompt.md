---
mode: agent
description: "In-container project setup. Run this from Copilot Chat after the environment check passes. Configures project identity, security baseline, license, compliance declaration, and Spec Kit."
tools: ['read', 'edit', 'search', 'terminal']
---

# Project Setup

You are running the project setup for a new project created from a TheSereyn template.

> **Prerequisite:** Run `/environment-check` first to confirm the dev container is healthy.

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

## Step 2 — Security Baseline

Establish the project's security foundation. These checks apply regardless of project structure.

1. **Review `.gitignore`** — confirm it excludes:
   - `appsettings.*.json`, `*.pfx`, `*.key`, `*.pem` (certificates and private keys)
   - `.env`, `.env.local` (environment secrets)
   - `appsettings.Local.json` (local configuration overrides)
2. **Enable GitHub Secret Scanning** — recommend the user enable it under Settings → Security → Secret scanning
3. **Configure branch protection** on `main` — recommend requiring PR reviews and status checks before merging

> **Note:** Implementation-specific steps like `dotnet user-secrets init` or project-level security configuration should wait until the project structure exists. These are covered by the `security-review-core` skill during development.

## Step 3 — Collect Project Info

Ask the user for:

1. **Project name** (e.g., `MyProject`, `Acme.OrderSystem`)
2. **Namespace root** (e.g., `Acme.OrderSystem`, `MyCompany.ProjectName`)
3. **Brief description** (one sentence describing what the project does)
4. **Problem / purpose** (1–2 sentences — what problem does this solve, or why does this project exist?)
5. **Key capabilities** (3–5 bullet points — what will this project do?)
6. **Target users** (who will use this — internal team, external developers, end users?)
7. **GitHub repo URL** (optional — e.g., `https://github.com/org/repo`)

## Step 4 — Resolve Placeholders

Update the following files, replacing placeholders:

| Placeholder | Value |
|-------------|-------|
| `{{PROJECT_NAME}}` | Project name from Step 3 |
| `{{NAMESPACE}}` | Namespace root from Step 3 |
| `{{DESCRIPTION}}` | Description from Step 3 |

Files to update:
- `.github/copilot-instructions.md`

> **Note:** Do not replace placeholders in `README.md` — it will be fully rewritten in Step 5.

Also update `LICENSE` with:

| Placeholder | Value |
|-------------|-------|
| `{{YEAR}}` | Current year (e.g., `2026`) |
| `{{AUTHOR}}` | Author or organisation name |

## Step 5 — Rewrite README

Using the project information from Step 3, rewrite `README.md` so it reads as **the project's own documentation** — not a template instruction manual.

### Structure to produce

1. **`# {Project name}`**
2. **Overview** — expand the brief description with the problem/purpose statement. Explain what the project does, why it exists, and who it's for.
3. **Key Capabilities** — bullet list from Step 3
4. **Getting Started** — keep Dev Container prerequisites and the build/test/run commands. Write them as project onboarding steps, not template instructions.
5. **Architecture** — if the current README has an Architecture section, preserve it as project documentation. Reframe any "This template is designed for..." language to "This project follows..."
6. **Key Conventions** — if present, keep as project coding standards
7. **Development** — build, test, and run commands. Include the Spec Kit / Squad workflow summary if it was in the original README — condense it to a short reference.
8. **License** — `See [LICENSE](LICENSE).`

### What to remove

- Any "Template: TheSereyn.Templates.X" headings
- "This is an AI-first template" notes or similar template-origin framing
- The "Manual Setup (Without Copilot)" section (setup is complete)
- The "What's Included" tooling table (tooling is already installed)
- "First-Time Setup" prompt instructions (setup is complete)

### Credit line

Add one line at the very end of the file:

`> Built with [TheSereyn.Templates](https://github.com/TheSereyn/TheSereyn.Templates)`

Write in a clear, professional tone. The reader should see a real project README, not a template walkthrough.

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

## Step 7 — Compliance Declaration

Ask the user two questions:

**Question 1:**

> "Does this project need to comply with any industry standards or compliance frameworks?"
>
> - ISO 27001 — Information security management
> - SOC 2 — Service organisation controls
> - PCI DSS — Payment card industry data security
> - HIPAA — Health information privacy (US)
> - GDPR — General data protection regulation (EU)
> - None / Not sure yet

**Question 2** (only if frameworks are selected):

> "Would you like to apply these now, or mark them for later configuration with `/compliance-setup`?"
>
> - **Apply now** — record the frameworks and activate the corresponding compliance skills
> - **Mark for later** — record the selection and defer detailed configuration

### Based on their response

**If "None / Not sure yet":**
- Record in `.github/copilot-instructions.md` under `## Compliance`: `No compliance frameworks selected. Run \`/compliance-setup\` when requirements are known.`
- Move on — do not ask follow-up questions about compliance

**If frameworks are selected and "Apply now":**
- Note the selected frameworks in `.github/copilot-instructions.md` under a new `## Compliance` section
- Append each selected compliance skill to the `## Skills` section in `.github/copilot-instructions.md`:
  `- \`compliance-<framework>\` — <Framework name> compliance guidance`
- Move on — do not ask per-framework deep questions here. Point the user to `/compliance-setup` for detailed configuration after the project is underway.

**If frameworks are selected and "Mark for later":**
- Record in `.github/copilot-instructions.md` under `## Compliance`: `Frameworks identified: <list>. Detailed configuration deferred — run \`/compliance-setup\` to configure.`
- Move on

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

## Step 10 — Initialise Spec Kit

Spec Kit provides the spec-driven development workflow for this project. Initialise it in the current directory:

```bash
specify init --here --ai copilot
```

Verify initialisation by confirming the `.specify/` directory was created and that the following slash commands are available in Copilot Chat:
- `/speckit.specify` — define specifications
- `/speckit.plan` — generate implementation plans
- `/speckit.tasks` — break down into tasks

> **Note:** If `specify` is not available, the post-create script may not have completed. Re-run it:
> ```bash
> bash .devcontainer/post-create.sh
> ```
> If `uv` is also missing, install it manually:
> ```bash
> python3 -m pip install --user uv
> export PATH="$HOME/.local/bin:$PATH"
> ```

## Step 11 — Summary and Next Steps

Provide a summary of what was configured, then suggest:

1. **Define your constitution** — Run `/speckit.constitution` in Copilot Chat with your project's core principles and constraints (reference `.github/copilot-instructions.md` for established standards)
2. **Specify what to build** — Run `/speckit.specify` to capture your requirements as executable specifications
3. **Plan and implement** — Use `/speckit.plan` → `/speckit.tasks` → hand off to Squad (`@squad`) for implementation

If compliance was deferred or skipped, include:

> **Compliance:** When your project's compliance requirements are clearer, run `/compliance-setup` to configure framework-specific guidance. This can be done at any time.

If compliance was applied, include:

> **Compliance:** Your compliance frameworks are recorded. For deeper per-framework configuration (data flows, control mappings, audit evidence), run `/compliance-setup` when you're ready.

## Self-Cleanup

After completing setup, instruct the user:

> You can delete the setup prompts now — they are one-time operations:
> ```bash
> rm .github/prompts/pre-container-setup.prompt.md
> rm .github/prompts/project-setup.prompt.md
> ```
>
> **Keep these** — they're re-runnable at any time:
> - `/environment-check` — health-check your development environment
> - `/compliance-setup` — configure or revise compliance frameworks
