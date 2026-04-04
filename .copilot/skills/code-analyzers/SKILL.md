---
name: "code-analyzers"
description: "Roslyn and StyleCop analyzer setup, configuration, and rule management for .NET projects. Use when setting up analyzers, customising rules, or troubleshooting analyzer warnings."
---

# Code Analyzers

## Default Configuration

The template ships with analyzers pre-configured in `Directory.Build.props`:

```xml
<PropertyGroup>
  <AnalysisLevel>latest-all</AnalysisLevel>
  <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
  <Nullable>enable</Nullable>
  <ImplicitUsings>enable</ImplicitUsings>
  <LangVersion>latest</LangVersion>
  <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
</PropertyGroup>

<ItemGroup>
  <PackageReference Include="StyleCop.Analyzers" Version="1.2.0-beta.*" PrivateAssets="all" />
</ItemGroup>
```

This gives maximum analyzer coverage:
- **All Roslyn code quality rules** (CAxxxx) at their recommended severity
- **All Roslyn code style rules** (IDExxxx) enforced in build
- **StyleCop rules** (SAxxxx) for consistent formatting and structure

## StyleCop Configuration

StyleCop is configured via `stylecop.json` in the solution root. The template defaults:

- Documentation requirements disabled (enable when project matures)
- `using` directives outside namespace, `System` first
- Newline required at end of file
- Hungarian notation disallowed

## Customising Rule Severity

Override rule severity in `.editorconfig`:

```ini
# Disable a specific rule
dotnet_diagnostic.SA1200.severity = none

# Downgrade to suggestion
dotnet_diagnostic.CA1062.severity = suggestion

# Upgrade to error
dotnet_diagnostic.CA2100.severity = error
```

Or in `Directory.Build.props` for build-time control:

```xml
<PropertyGroup>
  <NoWarn>$(NoWarn);SA1200</NoWarn>
</PropertyGroup>
```

## Common Suppressions

Only suppress rules with documented justification. Use `#pragma` with a comment:

```csharp
#pragma warning disable CA1054 // URI parameters should not be strings — external API contract
public void CallExternalApi(string url) { }
#pragma warning restore CA1054
```

Or use `[SuppressMessage]` for method/class-level suppression:

```csharp
[SuppressMessage("Design", "CA1054:URI parameters should not be strings",
    Justification = "External API contract requires string")]
public void CallExternalApi(string url) { }
```

## Blazor-Specific Notes

Blazor projects may need these adjustments:

- **SA1515** (single-line comment must be preceded by blank line) — can conflict with Razor `@code` blocks
- **SA1649** (file name must match first type name) — `.razor.cs` files follow component naming
- **IDE0044** (make field readonly) — Blazor `[Parameter]` properties can trigger false positives

Add Blazor-specific overrides in the Web project's `.editorconfig` if needed.

## Useful Commands

```bash
# Build with all warnings visible
dotnet build -warnaserror

# List all analyzer diagnostics for the solution
dotnet build --no-incremental 2>&1 | grep -E "warning (CA|SA|IDE)"

# Check for vulnerable packages
dotnet list package --vulnerable

# Update StyleCop to latest
dotnet add package StyleCop.Analyzers --version "1.2.0-beta.*"
```

## Rule Categories

| Prefix | Source | Focus |
|--------|--------|-------|
| CA | Roslyn Code Quality | Design, performance, security, reliability, naming |
| IDE | Roslyn Code Style | Formatting, expression preferences, using directives |
| SA | StyleCop | Documentation, spacing, ordering, readability, naming |

## References

- [Roslyn Analyzers — Code Quality Rules](https://learn.microsoft.com/dotnet/fundamentals/code-analysis/quality-rules/)
- [Roslyn Analyzers — Code Style Rules](https://learn.microsoft.com/dotnet/fundamentals/code-analysis/style-rules/)
- [StyleCop Analyzers](https://github.com/DotNetAnalyzers/StyleCopAnalyzers)
- [.editorconfig Reference](https://learn.microsoft.com/dotnet/fundamentals/code-analysis/configuration-files)

> **Note:** Verify rule IDs and configuration options against the current Microsoft Learn documentation, as new rules are added with each .NET release.
