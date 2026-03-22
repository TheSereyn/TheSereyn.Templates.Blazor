# {{PROJECT_NAME}}

{{DESCRIPTION}}

## Template: TheSereyn.Templates.Blazor

Full-stack template for .NET projects with Minimal APIs, Blazor UI, Worker Services, and shared contracts.

## Getting Started

### Prerequisites

- [Docker](https://www.docker.com/) or [Podman](https://podman.io/)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### First-Time Setup

1. Click **"Use this template"** on GitHub to create your new repository
2. Clone your new repo and open it in VS Code
3. When prompted, click **"Reopen in Container"**
4. Once the container is built, run the **first-time-setup** prompt:
   - Open Copilot Chat
   - Type: `@workspace /first-time-setup`
   - Follow the prompts to configure your project identity

### What's Included

| Component | Description |
|-----------|-------------|
| **Dev Container** | .NET 10, Node 22, GitHub CLI, Azure CLI, Docker-outside-of-Docker |
| **MCP Servers** | Microsoft Learn, Azure, GitHub |
| **Copilot Skills** | TUnit testing, project conventions, requirements gathering, Playwright CLI, **Blazor architecture** |
| **Business Analyst Agent** | Structured 10-phase requirements-gathering interview |
| **Squad** | AI development team (auto-installed via DevContainer) |
| **Code Quality** | StyleCop, .editorconfig, nullable reference types |

### Recommended Workflow

1. **Run first-time-setup** to configure project identity and verify environment
2. **Start with the Business Analyst** — `@Business Analyst` in Copilot Chat to generate requirements
3. **Use Squad** to design architecture and scaffold the solution
4. **Build iteratively** using the included skills and conventions

## Architecture

This template is designed for **full-stack** projects following **Clean Architecture**:

```
src/
├── Domain/           # Entities, value objects, domain events, interfaces
├── Application/      # Use cases, commands, queries, handlers, DTOs
├── Infrastructure/   # Database repos, external service clients, messaging
├── Api/              # ASP.NET Core Minimal API endpoints, DI composition root
├── Web/              # Blazor UI (Server, WASM, or Hybrid — decided per feature)
├── Web.Components/   # Reusable Razor Class Library (RCL) for shared UI components
├── Worker/           # Background processing with BackgroundService
└── Shared/           # Contracts, DTOs shared between projects
```

### Blazor Hosting Models

The hosting model should be decided **per feature** (this is an ask-first trigger):

| Model | Use When |
|-------|----------|
| **Blazor Server** | Server-only data, real-time updates, thin-client needed |
| **Blazor WebAssembly** | Offline capability, zero-trust client, reduced server load |
| **Blazor Hybrid** | Mix of both — feature-level decision |

See the `blazor-architecture` skill for detailed patterns and guidance.

## Development

```bash
# Build
dotnet build

# Test (TUnit on Microsoft Testing Platform)
dotnet test

# Run the API
dotnet run --project src/YourProject.Api/

# Run the Blazor app
dotnet run --project src/YourProject.Web/
```

## Key Conventions

- **API Style:** Minimal APIs with REPR pattern (one endpoint per file)
- **Error Handling:** RFC 9457 Problem Details for all errors
- **Testing:** TUnit on Microsoft Testing Platform (NOT xUnit/NUnit)
- **Pagination:** Cursor-based for all list endpoints
- **Observability:** OpenTelemetry (traces, metrics, logs)
- **Blazor:** Hosting model per feature, RCL for reusable components, minimal JS interop

See the `project-conventions`, `tunit-testing`, and `blazor-architecture` skills for detailed guidance.

## Links

- [TUnit Documentation](https://tunit.dev/docs/intro)
- [ASP.NET Core Minimal APIs](https://learn.microsoft.com/aspnet/core/fundamentals/minimal-apis)
- [Blazor Documentation](https://learn.microsoft.com/aspnet/core/blazor)
- [Blazor Performance](https://learn.microsoft.com/aspnet/core/blazor/performance)
- [Clean Architecture](https://learn.microsoft.com/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures#clean-architecture)
- [RFC 9457 — Problem Details](https://www.rfc-editor.org/rfc/rfc9457.html)

## License

[MIT](LICENSE)

---

*Composed from [TheSereyn.Templates](https://github.com/TheSereyn/TheSereyn.Templates) @ v0.1.1*
