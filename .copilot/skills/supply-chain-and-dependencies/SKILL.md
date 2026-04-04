---
name: "supply-chain-and-dependencies"
description: "Dependency provenance, typosquatting, lockfiles, transitive vulnerability management, and supply chain integrity for .NET"
domain: "security"
confidence: "high"
source: "manual — authored from canonical references"
---

## Context

Every NuGet package you reference is code you trust to run in your process. A single compromised or abandoned dependency — direct or transitive — can introduce vulnerabilities, data exfiltration, or build-time attacks. This skill covers dependency review triggers, package provenance, typosquatting detection, lockfile enforcement, transitive dependency risk, and CI-level supply chain controls for .NET projects.

AI-assisted coding tools (Copilot, ChatGPT) may suggest NuGet references derived from training data — packages that are outdated, renamed, or that never existed. Every `<PackageReference>` must be explicitly verified as intentional and legitimate.

## Best used for

All repositories with NuGet or dependency changes. Use this skill when reviewing PRs that add, update, or remove package references, modify `packages.lock.json`, change version ranges, or alter CI workflows that restore/build packages.

## Primary references

- NIST SP 800-218 Secure Software Development Framework (SSDF): https://csrc.nist.gov/pubs/sp/800/218/final
- NIST SP 800-218A Generative AI and SSDF Practices: https://csrc.nist.gov/pubs/sp/800/218/a/final
- NuGet Package Lock File: https://learn.microsoft.com/en-us/nuget/consume-packages/package-references-in-project-files#locking-dependencies
- GitHub Dependency Review Action: https://github.com/actions/dependency-review-action

## Patterns

### Dependency review triggers

Any of the following changes in a PR should trigger supply chain review:

- NuGet version bumps (patch, minor, or major).
- New `<PackageReference>` additions.
- Transitive dependency changes visible in `packages.lock.json`.
- Lockfile (`packages.lock.json`) created, deleted, or modified.
- `Directory.Packages.props` or `Directory.Build.props` changes affecting package versions.
- `nuget.config` changes (new feeds, feed ordering, feed credentials).

### Package provenance

Prefer well-known, actively maintained packages:

- **Official first:** `Microsoft.*`, `System.*`, `Azure.*` packages from verified Microsoft accounts.
- **Well-known community:** packages with high download counts, active maintainers, recent releases (e.g., Serilog, MediatR, FluentValidation).
- **Red flags:** low download counts (<1,000 total), single maintainer with no GitHub presence, no source repository linked, published only on unofficial feeds.

Check on nuget.org: downloads, last published date, source repository link, maintainer identity.

### Typosquatting detection

Attackers publish packages with names visually similar to popular ones:

| Legitimate | Typosquat examples |
|------------|-------------------|
| `Newtonsoft.Json` | `Newtonsoft-Json`, `NewtonsoftJson`, `Newtonsoft.JSon` |
| `Microsoft.Identity.Client` | `MicrosoftIdentity.Client`, `Microsoft.ldentity.Client` (lowercase L) |
| `Serilog.Sinks.Console` | `Serilog.Sink.Console`, `SerilogSinks.Console` |

**Review action:** for any new package, verify the exact package ID on nuget.org. Compare against the official documentation or GitHub repository of the library.

### Abandoned package detection

A package is a risk signal when:

- No release in 24+ months.
- Open security issues/CVEs with no maintainer response.
- Archived or deprecated GitHub repository.
- Maintainer account is inactive.

**Review action:** if the package is abandoned, look for maintained forks, official replacements, or evaluate inlining the needed functionality.

### NuGet dependency lockfiles

`packages.lock.json` records the exact resolved dependency graph (direct + transitive) for reproducible restores.

**Enable per project:**

```xml
<PropertyGroup>
  <RestorePackagesWithLockFile>true</RestorePackagesWithLockFile>
</PropertyGroup>
```

**Enforce in CI — fail if lockfile is out of date:**

```bash
dotnet restore --locked-mode
```

Or with MSBuild directly: `/p:RestoreLockedMode=true`

Without `--locked-mode`, CI silently resolves different transitive versions than the developer tested — breaking reproducibility and opening a supply chain gap.

### Transitive dependency risks

A direct dependency may pull in a vulnerable transitive package. You do not control transitive version resolution unless you act.

**Detect vulnerable transitive deps:**

```bash
dotnet list package --vulnerable --include-transitive
```

**Fix — pin the transitive dependency directly:**

```xml
<!-- Direct pin to override vulnerable transitive resolution -->
<PackageReference Include="System.Text.Json" Version="8.0.5" />
```

This forces NuGet to resolve at least the pinned version, overriding the lower transitive version.

### CI supply chain controls

**GitHub Dependency Review Action** blocks PRs that introduce known-vulnerable dependencies:

```yaml
- name: Dependency Review
  uses: actions/dependency-review-action@3b139cfc5fae8b618d3eae3675e383bb1769c019 # v4.5.0
  with:
    fail-on-severity: moderate
```

**Pin action versions with full SHA**, not mutable tags:

```yaml
# BAD — tag is mutable, can be pointed at compromised code
- uses: actions/checkout@v4

# GOOD — SHA is immutable
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
```

### SSDF alignment

- **PW.4 (Reuse existing, well-secured software):** verify third-party components are legitimate, maintained, and free of known vulnerabilities before adoption.
- **RV.2 (Assess, prioritize, and remediate vulnerabilities):** track known vulnerabilities in dependencies, prioritize by exploitability and exposure, and remediate or mitigate within defined SLAs.

### AI-generated code considerations

Copilot and other AI tools may generate code that:

- References packages that do not exist on nuget.org (hallucinated package names).
- Uses outdated package versions with known CVEs.
- Introduces unnecessary dependencies for functionality already available in the BCL.
- Adds packages with similar but incorrect names (AI-driven typosquatting).

**Review action:** verify every `<PackageReference>` in AI-generated code against nuget.org. Confirm the package is necessary and the version is current.

## Anti-Patterns

- Floating version ranges: `<PackageReference Include="Newtonsoft.Json" Version="*" />` — no version control.
- Wildcard pre-release versions: `Version="13.0.*-*"` — pulls untested pre-release builds.
- No lockfile in CI: `dotnet restore` without `--locked-mode` silently resolves different versions.
- Suppressing vulnerability warnings: `<NoWarn>NU1903</NoWarn>` without documented justification.
- Adding packages from untrusted NuGet feeds without review.
- Blindly accepting Dependabot PRs without reviewing the changelog and diff.
- Pinning action tags instead of SHAs in CI workflows that handle dependency operations.

## Examples

**BAD — floating version range:**

```xml
<PackageReference Include="Newtonsoft.Json" Version="*" />
```

**GOOD — pinned version:**

```xml
<PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
```

**BAD — no lockfile enforcement in CI:**

```yaml
- run: dotnet restore
```

**GOOD — locked-mode restore in CI:**

```yaml
- run: dotnet restore --locked-mode
```

**BAD — mutable action tag:**

```yaml
- uses: actions/dependency-review-action@v4
```

**GOOD — pinned SHA with version comment:**

```yaml
- uses: actions/dependency-review-action@3b139cfc5fae8b618d3eae3675e383bb1769c019 # v4.5.0
```

**BAD — suppressed vulnerability warning with no justification:**

```xml
<NoWarn>NU1903</NoWarn>
```

**GOOD — acknowledged with documented justification:**

```xml
<!-- NU1903: System.Net.Http 4.3.0 — transitive via Microsoft.Extensions.Logging 2.x.
     CVE-2018-8292 not exploitable in this service (no outbound HTTP via this path).
     Tracked in JIRA-1234, will resolve when upgrading to .NET 8. -->
<NoWarn>NU1903</NoWarn>
```

## Review cues

- [ ] Any new `<PackageReference>` — verify package exists on nuget.org with expected name, publisher, and download count.
- [ ] Version changes — check release notes for breaking changes and security fixes.
- [ ] `packages.lock.json` present and `--locked-mode` enforced in CI restore step.
- [ ] Run `dotnet list package --vulnerable --include-transitive` — no unmitigated findings.
- [ ] No floating version ranges (`*`, `[1.0,)`) unless explicitly justified.
- [ ] GitHub Actions in dependency workflows use pinned SHAs, not mutable tags.
- [ ] `nuget.config` changes — no untrusted feeds added; feed order is intentional.
- [ ] Dependabot PRs include changelog review, not just green CI.
- [ ] AI-generated `<PackageReference>` entries confirmed against nuget.org.
- [ ] Abandoned packages (24+ months no release) flagged for replacement.

## Good looks like

- All packages pinned to exact versions; `Directory.Packages.props` used for centralized version management.
- `packages.lock.json` committed and CI runs `dotnet restore --locked-mode`.
- `dotnet list package --vulnerable --include-transitive` returns no actionable findings.
- GitHub Dependency Review Action runs on every PR and blocks on moderate+ severity.
- New packages are justified in the PR description with a link to the official package page.
- Dependabot is enabled with a reviewed `dependabot.yml` configuration.
- CI action versions are pinned to full SHAs with version comments.
- No suppressed vulnerability warnings without documented, time-bound justification.

## Common findings / likely remediations

| Finding | Severity | Likely remediation |
|---------|----------|--------------------|
| Vulnerable transitive dependency | High | Pin the transitive package directly with a safe version |
| No `packages.lock.json` in repository | Medium | Enable `RestorePackagesWithLockFile`, commit lockfile, add `--locked-mode` to CI |
| Floating version range (`*` or open range) | High | Pin to exact version; use Central Package Management |
| Suspicious or typosquatted package name | Critical | Remove immediately; verify correct package ID on nuget.org |
| Unpinned GitHub Action in CI workflow | Medium | Replace tag with full SHA; add version comment |
| Abandoned package (no update in 24+ months) | Medium | Evaluate maintained alternatives or fork; document risk acceptance if retained |
| `NU1903` warning suppressed without justification | Medium | Add documented justification with tracking issue and timeline |
| Dependabot PR merged without changelog review | Low | Establish team process: review changelog and diff before merge |
| AI-generated package reference not on nuget.org | High | Remove the reference; find the correct package or implement without dependency |
| Untrusted NuGet feed added to `nuget.config` | High | Remove feed; discuss with team whether the feed is necessary and trustworthy |
