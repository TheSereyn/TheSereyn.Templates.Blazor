---
name: "blazor-architecture"
description: "Blazor hosting model guidance, multi-frontend patterns, RCL strategy, performance, component lifecycle, state management, and DI lifetime rules for Blazor projects"
---

# Blazor Architecture

## Hosting Model Guidance

Choose the hosting model **per feature** based on requirements. This is an ask-first trigger — do not assume without confirming.

### Server

- **Use when:** Real-time updates needed (SignalR), server-only data/logic, thin-client environments, rapid prototyping
- **Advantages:** Full access to server resources, smaller download size, works on thin clients
- **Trade-offs:** Requires persistent connection, higher server load per user, latency-sensitive to network quality
- **DI lifetime:** `Scoped` = per-circuit (per user session)

### WebAssembly (WASM)

- **Use when:** Offline capability needed, zero-trust client requirements, reduced server load, CDN-friendly deployment
- **Advantages:** Runs entirely in browser, works offline, scalable (no server per-user cost)
- **Trade-offs:** Larger initial download, limited to browser sandbox, no direct server resource access
- **DI lifetime:** `Scoped` = per-application instance

### Hybrid

- **Use when:** Different features have different requirements, progressive enhancement needed
- **Advantages:** Best of both worlds per feature
- **Trade-offs:** More complex hosting configuration, must manage both models

## Multi-Frontend Patterns

A single API can serve multiple Blazor applications:

```
API (Minimal APIs)
├── Web.Portal     (Blazor Server — internal staff)
├── Web.Customer   (Blazor WASM — external customers)
└── Web.Admin      (Blazor Server — administration)
```

Each frontend:
- Has its own Blazor project
- References only Shared contracts/DTOs
- Authenticates independently (different scopes/roles)
- WASM clients call the API over HTTP; Server apps can call the Application layer directly

## RCL Strategy (Razor Class Libraries)

Use RCLs for reusable UI components shared across multiple frontends:

```
src/
├── Web.Components/     # Shared RCL — buttons, forms, layouts, data display
├── Web.Portal/         # Portal-specific pages and components
└── Web.Customer/       # Customer-specific pages and components
```

### RCL Rules

- Components in RCLs should be presentation-only (no service injection for business logic)
- RCLs reference only Shared contracts — never domain or infrastructure
- Use `[Parameter]` for data and `[EventCallback]` for actions
- Keep JS interop in the RCL if the component requires it (encapsulate, don't leak)

## Performance

### Rendering

- Use `@key` on list items to help the diffing algorithm
- Use `Virtualize<T>` for large lists instead of rendering all items
- Use `ShouldRender()` to skip unnecessary re-renders
- Use streaming rendering (`[StreamRendering]`) for slow-loading data
- Debounce input events that trigger expensive operations

### State Management

- Prefer cascading parameters for simple state (theme, auth)
- Use scoped services for per-circuit/per-app state
- For complex state, use a state container pattern (observable service + `StateHasChanged`)
- Avoid `static` state — it's shared across all users in Server mode

### JS Interop Minimisation

- Prefer Blazor-native solutions over JS interop wherever possible
- When JS interop is needed:
  - Use `IJSRuntime` for simple calls
  - Use `IJSObjectReference` for module imports (lazy loading)
  - Dispose JS references properly (`IAsyncDisposable`)
  - Never pass large data through JS interop — use streaming APIs

### WASM Specific

- Consider AOT compilation for CPU-bound operations
- Use lazy assembly loading for large applications
- Enable Brotli compression for assets
- Profile download size and trim unused assemblies

## Component Lifecycle

Key lifecycle methods in order:

1. `SetParametersAsync` — Parameters set from parent
2. `OnInitialized` / `OnInitializedAsync` — First render initialization
3. `OnParametersSet` / `OnParametersSetAsync` — After parameters change
4. `OnAfterRender` / `OnAfterRenderAsync` — After DOM update (`firstRender` parameter for one-time setup)

### Rules

- Never call `StateHasChanged()` inside `OnInitialized` — it's already going to render
- Use `firstRender` check in `OnAfterRenderAsync` for JS interop setup
- Implement `IAsyncDisposable` to clean up event handlers, timers, and JS references
- Use `CancellationTokenSource` tied to disposal for async operations

## DI Lifetime Guidance

| Lifetime | Blazor Server | Blazor WASM |
|----------|--------------|-------------|
| **Transient** | New instance per injection | New instance per injection |
| **Scoped** | Per circuit (per user session) | Per application instance |
| **Singleton** | Shared across all circuits | Same as Scoped (only one instance) |

### Rules

- Use **Scoped** for user-specific state (auth, preferences, cart)
- Use **Transient** for stateless services
- Use **Singleton** sparingly in Server — it's shared across ALL users
- In WASM, Scoped and Singleton are effectively the same — prefer Scoped for consistency
- Never inject Scoped services into Singletons (captive dependency)

## Sharing Types Between API and Client

- **Share:** DTOs, request/response records, enums, constants (via Shared/Contracts project)
- **Never share:** Domain entities, value objects, repository interfaces, infrastructure types
- WASM clients are untrusted — all validation must be repeated server-side
