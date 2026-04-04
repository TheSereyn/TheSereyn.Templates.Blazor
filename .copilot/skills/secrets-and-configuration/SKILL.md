---
name: "secrets-and-configuration"
description: "Secure secrets and configuration management for .NET"
domain: "security"
confidence: "high"
source: "manual — authored from canonical references"
---

## Context

Committed secrets are a permanent breach risk — they live in git history forever unless the repository is surgically cleaned. Prevention is the only reliable control. This skill covers detecting committed secrets, environment and appsettings hygiene, key/secret management patterns, and redaction expectations for .NET services.

## Best used for

All .NET services and deployment-sensitive repositories. Use this skill when reviewing configuration files, auditing secret management practices, triaging secret scanning alerts, and verifying log redaction.

## Primary references

- Secure ASP.NET Core Blazor WebAssembly: <https://learn.microsoft.com/en-us/aspnet/core/blazor/security/webassembly/?view=aspnetcore-10.0>
- NIST SP 800-218 SSDF: <https://csrc.nist.gov/pubs/sp/800/218/final>

## Patterns

### Core principle: secrets must never be committed

- `appsettings.Development.json` must never contain real credentials.
- `.env` files must be in `.gitignore` before any secrets are placed in them.
- Connection strings with passwords must never appear in committed config files.
- API keys, client secrets, certificate private keys — none of these belong in source control.

### Detecting committed secrets

Red flags in code review:

- `appsettings.json` with `Password=`, `AccountKey=`, `ApiKey=`, `Secret=` literal values.
- `connectionString` with embedded credentials (not `${VARIABLE}` or `#{placeholder}`).
- Any `private_key`, `-----BEGIN RSA PRIVATE KEY-----`, or `-----BEGIN CERTIFICATE-----` block in source.
- Base64-encoded blobs in config that decode to key material.
- Environment variable values hardcoded in `Dockerfile` or `docker-compose.yml`.

GitHub Secret Scanning automatically detects many patterns — ensure it is enabled on the repo.

### ASP.NET Core configuration hygiene

**ASP.NET Core ConfigurationBuilder loading order** (later sources override earlier):

```
appsettings.json              ← non-sensitive defaults only          (lowest precedence)
appsettings.Development.json  ← development overrides, never real secrets
User Secrets (local dev)      ← developer secrets via dotnet user-secrets
Environment variables         ← CI/CD pipeline secrets and cloud config
CLI arguments                 ← highest precedence
```

Production secret stores (Azure Key Vault, AWS Secrets Manager, HashiCorp Vault) are typically added as a configuration provider at startup and load into the configuration pipeline — effectively overriding app settings but below environment variables. Treat them as the authoritative source for production secrets rather than a precedence tier.

> **Note:** Environment variables override user-secrets in the default ASP.NET Core configuration order. This means env vars in the dev environment will shadow user-secrets values — useful for testing but a common source of confusion.

**`dotnet user-secrets`** is the correct tool for local development secrets:

```bash
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:Default" "Server=..."
```

User secrets are stored outside the project directory — never committed:
- **Windows:** `%APPDATA%\Microsoft\UserSecrets\<user-secrets-id>\secrets.json`
- **Linux/macOS:** `~/.microsoft/usersecrets/<user-secrets-id>/secrets.json`

### Configuration-driven security posture risks

Some configuration choices directly affect security posture:

- `ASPNETCORE_ENVIRONMENT=Development` in production → developer exception pages, relaxed CORS, verbose errors.
- `Kestrel:Certificates:Default:Password` in appsettings.json → certificate private key exposed.
- `Authentication:JwtBearer:Authority` pointing to wrong issuer → tokens from other systems accepted.
- Wildcard CORS in appsettings with no environment gating → production API open to all origins.
- Feature flags enabling unauthenticated access: verify these are environment-gated.

### Key and secret management expectations

| Environment | Mechanism | Notes |
|-------------|-----------|-------|
| Development | `dotnet user-secrets` | Stored outside project directory, never committed |
| CI/CD | GitHub Actions secrets or pipeline variables | Never literal values in workflow YAML |
| Production | Azure Key Vault, AWS Secrets Manager, HashiCorp Vault | Accessed via managed identity, not stored credentials |

- **Key rotation:** secrets should have a rotation policy; note when rotation is not implemented.
- **Expiry:** short-lived tokens preferred over long-lived API keys.

### Log and review output redaction

- Secrets and tokens must never appear in log output.
- Structured logging: use named placeholders with non-sensitive values only; avoid logging request bodies or headers wholesale. With **Serilog**, the `{@object}` destructuring prefix expands objects — never use it on types containing credentials or tokens.
- Serilog destructuring: `[Destructure.ByTransforming<>]` to strip sensitive fields before logging.
- Review findings: never quote actual secret values — use `[REDACTED]` in all review output.
- Application Insights / OpenTelemetry: verify sensitive data is not inadvertently included in traces or metrics.

## Anti-Patterns

- `appsettings.json` with any credential, key, or secret literal value.
- `Environment.GetEnvironmentVariable("SECRET")` with a fallback to a hardcoded value (e.g., `?? "default_password"`).
- Secrets logged with structured logging (`_logger.LogInformation("Token: {token}", bearerToken)`).
- GitHub Actions: `echo ${{ secrets.MY_SECRET }}` in a run step (GitHub masks but still risky).
- Docker: `ENV DB_PASSWORD=mysecret` in Dockerfile.
- Connection string embedded in config with password: `Server=...;Password=hardcoded`.

## Examples

**BAD — hardcoded connection string in appsettings.json:**

```json
{
  "ConnectionStrings": {
    "Default": "Server=prod-db;Database=MyApp;User Id=admin;Password=S3cret!;"
  }
}
```

**GOOD — placeholder with runtime override:**

```json
{
  "ConnectionStrings": {
    "Default": ""
  }
}
```

Actual value provided via environment variable or Key Vault at runtime.

**BAD — secret fallback to hardcoded value:**

```csharp
var apiKey = Environment.GetEnvironmentVariable("API_KEY") ?? "default-key-12345";
```

**GOOD — fail fast when secret is missing:**

```csharp
var apiKey = Environment.GetEnvironmentVariable("API_KEY")
    ?? throw new InvalidOperationException("API_KEY environment variable is not set.");
```

**BAD — logging a bearer token:**

```csharp
_logger.LogInformation("Authenticated with token: {Token}", bearerToken);
```

**GOOD — log the event, not the secret:**

```csharp
_logger.LogInformation("User {UserId} authenticated successfully.", userId);
```

**BAD — secret in Dockerfile:**

```dockerfile
ENV DB_PASSWORD=mysecret
```

**GOOD — secret injected at runtime:**

```dockerfile
# DB_PASSWORD provided via orchestrator secrets (e.g., Docker secrets, K8s secrets)
```

## Review cues

- Any file named `appsettings*.json` → scan for `Password`, `Secret`, `Key`, `AccountKey`, `Token` literal values.
- `Dockerfile` or `docker-compose.yml` → scan for `ENV` directives with credential-like values.
- `.github/workflows/*.yml` → verify secrets are referenced as `${{ secrets.NAME }}`, never inline.
- `ILogger` / `Serilog` calls → check that request bodies, headers, and tokens are not logged.
- `Program.cs` / `Startup.cs` → verify configuration providers load secrets from user-secrets (dev) or vault (prod), not from appsettings.
- `.gitignore` → confirm `.env`, `appsettings.Development.json` (if it contains secrets), and certificate files are excluded.

## Good looks like

- `appsettings.json` contains only non-sensitive defaults (URLs, feature flags, timeouts).
- Local development uses `dotnet user-secrets` — no `.env` files with real credentials committed.
- CI/CD pipelines inject secrets via GitHub Actions secrets or equivalent, never as literal YAML values.
- Production secrets are managed by Azure Key Vault (or equivalent) and accessed via managed identity.
- Secrets have a documented rotation policy.
- Log output is reviewed for accidental secret exposure; Serilog destructuring policies strip sensitive fields.
- GitHub Secret Scanning is enabled and alerts are triaged promptly.
- Missing secrets cause immediate startup failure (fail-fast), not silent fallback to insecure defaults.

## Common findings / likely remediations

| Finding | Severity | Likely remediation |
|---------|----------|--------------------|
| Real password in `appsettings.json` | Critical | Remove immediately, rotate credential, move to user-secrets (dev) or Key Vault (prod) |
| Private key file committed to repo | Critical | Remove from history (`git filter-repo`), revoke and reissue the key |
| `ASPNETCORE_ENVIRONMENT=Development` in production config | High | Set to `Production`; audit for development-only middleware enabled in prod |
| Connection string with embedded password in Docker Compose | High | Use Docker secrets or environment variable injection |
| Secret logged via `ILogger` | High | Remove secret from log arguments; log event identifiers instead |
| `Environment.GetEnvironmentVariable` with hardcoded fallback | Medium | Replace fallback with `throw` to fail fast |
| GitHub Actions workflow echoing a secret | Medium | Remove `echo` statement; use `add-mask` if output is required |
| No secret rotation policy documented | Medium | Establish rotation schedule; implement automated rotation where possible |
| `.env` file not in `.gitignore` | High | Add to `.gitignore`; verify no secrets are already committed |
| Base64 blob in config that decodes to key material | High | Remove from config; store in vault; rotate the key |
