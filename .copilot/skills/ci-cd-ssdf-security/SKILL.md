---
name: "ci-cd-ssdf-security"
description: "GitHub Actions security hardening, CI/CD pipeline integrity, release security, and SSDF alignment"
domain: "security"
confidence: "high"
source: "manual — authored from canonical references"
---

## Context

CI/CD pipelines are high-value targets — they hold secrets, produce deployable artifacts, and run with elevated permissions. A misconfigured GitHub Actions workflow can leak credentials, allow unauthorized deployments, or execute attacker-controlled code with write access to the repository. This skill covers GitHub Actions permission hardening, pinned action SHAs, secret hygiene, OIDC federation, `pull_request_target` risks, release security, and alignment with NIST SSDF practices — including AI-specific considerations from SP 800-218A.

## Best used for

GitHub Actions, Azure DevOps, release workflows, and compliance-sensitive repos. Use this skill when reviewing workflow files, pipeline configurations, deployment processes, and any CI/CD changes that affect build integrity or secret handling.

## Primary references

- NIST SP 800-218 Secure Software Development Framework (SSDF): https://csrc.nist.gov/pubs/sp/800/218/final
- NIST SP 800-218A Generative AI and SSDF Practices: https://csrc.nist.gov/pubs/sp/800/218/a/final
- GitHub Actions Security Hardening: https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions
- Microsoft Learn — Custom CodeQL Queries: https://learn.microsoft.com/en-us/code-security/code-scanning/creating-an-advanced-setup-for-code-scanning/customizing-your-advanced-setup-for-code-scanning

## Patterns

### `GITHUB_TOKEN` minimum permissions

Without a `permissions:` block, the token defaults to `write-all`. Every workflow must declare minimum permissions at the workflow level, granting additional scopes only at the job level where needed.

**Least-privilege baseline (workflow level):**
```yaml
permissions: {}  # deny all at workflow level; grant per job only
```

**Scope only what each job needs:**
```yaml
jobs:
  build:
    permissions:
      contents: read
  release:
    permissions:
      contents: write
      attestations: write
      id-token: write
```

### Pinned action SHAs

Tags like `@v4` are mutable — a compromised upstream can retag to malicious code. Pin to full commit SHAs with version comments. Use `npx pin-github-action .github/workflows/*.yml` to automate.

### Secrets in workflows

- Always use `${{ secrets.NAME }}` — never pass secrets through environment variable indirection.
- Never `echo` a secret. GitHub masks known secrets, but novel derivations may leak.
- Use `::add-mask::` for dynamically generated sensitive values. Note: masking only applies to log output **after** the line where it is set — any value logged before the mask command remains visible.
- Never pass secrets to untrusted third-party actions — audit source first.

### `pull_request_target` risk

`pull_request_target` runs in the **base repository context** with write permissions and access to secrets — even for fork PRs. If the workflow checks out fork code, an attacker controls what runs with elevated privileges.

If `pull_request_target` is genuinely required (e.g., labeling), never check out or execute code from the PR head — only read metadata.

### OIDC federation vs long-lived credentials

Long-lived cloud credentials stored as secrets do not expire, cannot be scoped to a single run, and are hard to rotate. Prefer OIDC federation (`id-token: write`) for Azure, AWS, and GCP — tokens are short-lived, audience-scoped, and tied to the specific workflow run.

### Build reproducibility

Reproducible builds require deterministic dependency resolution:

- Commit `packages.lock.json` and restore with `--locked-mode`.
- Pin all tool versions (SDK, runtime, Node.js) in `global.json` or workflow `setup-*` actions.
- Avoid floating refs in action inputs (e.g., `dotnet-version: 8.x` — use `8.0.401`).

### Static analysis in CI

Enable CodeQL or GitHub Advanced Security. Requires `security-events: write` to upload SARIF results to the Security tab. Configure for all project languages; run on every PR and push to the default branch.

### Release security

- **Environment protection rules:** require manual approval for production.
- **Required reviewers:** at least one reviewer before deployment.
- **Artifact attestation:** `actions/attest-build-provenance` for signed SLSA provenance (requires `attestations: write` and `id-token: write` permissions).
- **Branch protection:** require CI pass and PR reviews before merge to `main`; disallow direct pushes.

### SSDF alignment

- **PO.1 (Define security requirements):** CI/CD pipelines should enforce security requirements automatically — static analysis, dependency review, secret scanning.
- **PW.4 (Reuse existing, well-secured software):** pin action versions, verify third-party actions before adoption, prefer official actions from `actions/*` and verified publishers.
- **RV.1 (Identify vulnerabilities):** integrate CodeQL, dependency review, and secret scanning into every PR.
- **RV.2 (Assess, prioritize, and remediate):** track and triage findings from CI security tools within defined SLAs.

### AI-generated workflow considerations (SP 800-218A)

AI tools can generate or modify GitHub Actions workflows. Risks include:

- Suggesting `pull_request_target` without understanding the security implications.
- Omitting `permissions:` blocks (defaulting to overly broad access).
- Using mutable action tags instead of pinned SHAs.
- Introducing workflow steps that echo or expose secrets.
- Generating composite actions with unnecessary `GITHUB_TOKEN` usage.

**Review action:** treat all AI-generated workflow changes as untrusted input. Review line-by-line against this skill's patterns before merging.

## Anti-Patterns

- No `permissions:` block in workflow (defaults to `write-all`).
- `pull_request_target` with `actions/checkout` referencing `github.event.pull_request.head.sha`.
- Secrets echoed to logs: `echo ${{ secrets.TOKEN }}` or `env | grep`.
- Mutable action tags (`@v4`, `@main`) instead of pinned SHAs.
- Long-lived cloud credentials as secrets instead of OIDC federation.
- No branch protection rules on `main` — direct pushes allowed.
- CodeQL or security scanning not enabled on repositories with deployed services.
- Missing `environment:` gates for production deployments.
- AI-generated workflow files merged without manual security review.

## Examples

**BAD — no permissions, mutable tags, secret echo, untrusted action:**

```yaml
on: push
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Deploying with token ${{ secrets.DEPLOY_TOKEN }}"
      - uses: some-org/deploy-action@main
        with:
          token: ${{ secrets.DEPLOY_TOKEN }}
```

**GOOD — minimal permissions, pinned SHAs, OIDC, environment gate:**

```yaml
permissions:
  contents: read

on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - uses: azure/login@a457da9ea143d694b1b9c7c869ebb04ebe844ef5 # v2.3.0
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      - run: dotnet publish -c Release
```

**BAD — `pull_request_target` checking out fork code:**

```yaml
on: pull_request_target
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
        with:
          ref: ${{ github.event.pull_request.head.sha }}
      - run: dotnet test  # attacker-controlled code runs with write token
```

**GOOD — `pull_request` for untrusted code:**

```yaml
on: pull_request
jobs:
  test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - run: dotnet test
```

## Review cues

- [ ] Every workflow file has an explicit `permissions:` block at the workflow or job level.
- [ ] Permissions follow least privilege — only the scopes the job actually needs.
- [ ] All `uses:` references are pinned to full commit SHAs with version comments.
- [ ] No `pull_request_target` workflows check out or execute PR head code.
- [ ] Secrets are accessed only via `${{ secrets.NAME }}` — never echoed, printed, or passed to untrusted actions.
- [ ] Cloud authentication uses OIDC federation, not long-lived credential secrets.
- [ ] Production deployments use `environment:` with protection rules and required reviewers.
- [ ] CodeQL or equivalent static analysis runs on every PR and pushes to default branch.
- [ ] `security-events: write` is granted only to jobs that upload SARIF results.
- [ ] Branch protection requires CI pass and PR review before merge to `main`.
- [ ] AI-generated workflow changes have been manually reviewed against these patterns.
- [ ] Artifact attestation is configured for release artifacts.

## Good looks like

- Every workflow declares `permissions: contents: read` at minimum, with additional scopes only at job level.
- All action references are pinned to immutable SHAs with descriptive version comments.
- Cloud auth uses OIDC federation — no long-lived credential secrets in the repository.
- `pull_request_target` is not used, or is used only for metadata operations (labeling) without checking out PR code.
- Secrets are never logged; `::add-mask::` is used for dynamically generated sensitive values.
- CodeQL runs on every PR; SARIF results are uploaded to GitHub Security tab.
- Production deployments require environment approval gates and reviewer sign-off.
- Build artifacts have signed provenance attestations.
- Branch protection is enforced: CI must pass, PRs required, no direct pushes to `main`.
- AI-generated workflow modifications are flagged for manual review in the PR process.

## Common findings / likely remediations

| Finding | Severity | Likely remediation |
|---------|----------|--------------------|
| No `permissions:` block (defaults to `write-all`) | High | Add explicit `permissions:` with minimum required scopes |
| `pull_request_target` with checkout of PR head | Critical | Switch to `pull_request` trigger or remove checkout of untrusted ref |
| Secrets echoed to workflow logs | Critical | Remove `echo` statements; use `::add-mask::` for dynamic values |
| Mutable action tags (`@v4`, `@main`) | Medium | Pin to full SHA; add version comment; use `pin-github-action` tooling |
| Long-lived cloud credentials as secrets | High | Migrate to OIDC federation with `id-token: write` permission |
| No branch protection on default branch | High | Enable required PR reviews, required CI checks, disallow direct push |
| CodeQL / static analysis not configured | Medium | Add CodeQL workflow with `security-events: write`; configure for project languages |
| No environment protection for production | High | Create `production` environment with required reviewers and wait timer |
| AI-generated workflow merged without review | Medium | Establish team policy: all workflow changes require manual security review |
| No artifact attestation on release builds | Medium | Add `actions/attest-build-provenance` to release workflow |
