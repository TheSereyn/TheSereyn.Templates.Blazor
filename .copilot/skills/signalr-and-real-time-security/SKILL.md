---
name: "signalr-and-real-time-security"
description: "Hub connection identity and authorization, token lifetime and query-string exposure, circuit state assumptions, group authorization, and per-invocation re-authorization for SignalR and Blazor real-time scenarios"
domain: "security"
confidence: "high"
source: "Microsoft SignalR security docs, ASP.NET Core Blazor security docs"
---

# SignalR and Real-Time Security

## Context

SignalR establishes long-lived persistent connections (WebSocket, SSE, long-polling). Identity is captured at connect time from the HTTP handshake. In Blazor Server, each user session is a circuit backed by a SignalR connection. These persistent connections create unique security considerations around token lifetime, stale identity, authorization enforcement, and state management that do not exist in stateless HTTP request patterns.

## Patterns

### 1. Per-Invocation Authorization on Hub Methods

`[Authorize]` on a Hub class validates identity at connection time only. Individual hub methods must enforce their own authorization policies — "connected" does not mean "authorized for every operation."

**Vulnerable:**
```csharp
[Authorize] // Checked at connection time only
public class AdminHub : Hub
{
    // Any connected user can invoke this — no per-method check
    public async Task DeleteUser(string userId)
    {
        await _userService.Delete(userId);
    }
}
```

**Safe:**
```csharp
[Authorize]
public class AdminHub : Hub
{
    [Authorize(Policy = "RequireAdminRole")]
    public async Task DeleteUser(string userId)
    {
        // Policy enforced on every invocation
        await _userService.Delete(userId);
    }
}
```

### 2. Use Server-Side Identity, Not Client-Supplied IDs

Always use `Context.UserIdentifier` for user-scoped operations. Never trust a user ID supplied by the client in the hub method parameters. `Context.UserIdentifier` is populated by `IUserIdProvider`, which defaults to the `NameIdentifier` claim — customize the provider if your identity model uses a different claim.

**Vulnerable:**
```csharp
public async Task SendPrivateMessage(string targetUserId, string fromUserId, string message)
{
    // Client controls fromUserId — impersonation is trivial
    await Clients.User(targetUserId).SendAsync("ReceiveMessage", fromUserId, message);
}
```

**Safe:**
```csharp
public async Task SendPrivateMessage(string targetUserId, string message)
{
    var fromUserId = Context.UserIdentifier
        ?? throw new HubException("User identity not available.");
    await Clients.User(targetUserId).SendAsync("ReceiveMessage", fromUserId, message);
}
```

### 3. Token Query-String Exposure

SignalR passes the access token as `?access_token=` in the query string for WebSocket transport. This value appears in server logs, proxy logs, and load balancer logs.

**Safe — extract token; rely on default log redaction:**
```csharp
options.Events = new JwtBearerEvents
{
    OnMessageReceived = context =>
    {
        var accessToken = context.Request.Query["access_token"];
        if (!string.IsNullOrEmpty(accessToken)
            && context.HttpContext.Request.Path.StartsWithSegments("/hubs"))
            context.Token = accessToken;
        return Task.CompletedTask;
    }
};

// NOTE: Do NOT call AddHttpLogging with QueryStringParameterNames.Add("access_token").
// QueryStringParameterNames is an *allowlist* — adding a name causes its value to be
// INCLUDED in logs. The default behavior redacts all query string values; leave it as-is.
```

### 4. Group Authorization

Verify that a user is authorized to join a group before adding them. Never let the client choose arbitrary group names without server-side validation.

**Vulnerable:**
```csharp
public async Task JoinGroup(string groupName)
{
    // Client picks any group — no authorization check
    await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
}
```

**Safe:**
```csharp
public async Task JoinGroup(string groupName)
{
    var userId = Context.UserIdentifier
        ?? throw new HubException("User identity not available.");
    if (!await _authService.CanAccessGroup(userId, groupName))
    {
        throw new HubException("Not authorized for this group.");
    }
    await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
}
```

### 5. Circuit and Reconnection Identity

In Blazor Server, each circuit holds server-side state. Scoped services are bound to the circuit lifetime — they are created when the circuit starts and disposed when it ends. On reconnect, a new connection is established and identity must be re-validated. Never assume a reconnected circuit retains the same authorization context.

**Vulnerable:**
```csharp
// Caching identity at circuit start — stale after token expiry or role change
public class UserStateService
{
    public ClaimsPrincipal? CachedUser { get; set; }

    public void Initialize(ClaimsPrincipal user)
    {
        CachedUser = user; // Never refreshed
    }
}
```

**Safe:**
```csharp
// Re-validate on access; use AuthenticationStateProvider for current state
public class UserStateService
{
    private readonly AuthenticationStateProvider _authProvider;

    public UserStateService(AuthenticationStateProvider authProvider)
    {
        _authProvider = authProvider;
    }

    public async Task<ClaimsPrincipal> GetCurrentUserAsync()
    {
        var state = await _authProvider.GetAuthenticationStateAsync();
        return state.User;
    }
}
```

### 6. Avoid Broadcasting Sensitive Data

When using `IHubContext<T>` from services, be explicit about message targets. Broadcasting sensitive data to all connections is a data leak.

**Vulnerable:**
```csharp
public class PayrollService
{
    private readonly IHubContext<NotificationHub> _hub;
    public async Task ProcessPayroll(PayrollResult result)
    {
        await _hub.Clients.All.SendAsync("PayrollComplete", result);
    }
}
```

**Safe:**
```csharp
public class PayrollService
{
    private readonly IHubContext<NotificationHub> _hub;
    public async Task ProcessPayroll(string employeeId, PayrollResult result)
    {
        await _hub.Clients.User(employeeId).SendAsync("PayrollComplete", result);
    }
}
```

## Examples

| Scenario | Approach |
|----------|----------|
| Admin hub method | `[Authorize(Policy = "Admin")]` on the method, not just the hub |
| User-to-user messaging | Derive sender from `Context.UserIdentifier`; never accept from client |
| Joining a project channel | Validate user membership server-side before `Groups.AddToGroupAsync` |
| Token refresh mid-session | Handle reconnect; re-validate identity on new connection |
| Sensitive notification | Send via `Clients.User(id)`, never `Clients.All` |

## Anti-Patterns

- Relying on connection-time `[Authorize]` for all hub method access control
- Trusting client-supplied user IDs or group names without server-side verification
- Logging query strings containing `access_token` at Debug or Information level
- Caching `ClaimsPrincipal` in a circuit-scoped service without refresh
- Broadcasting sensitive messages via `Clients.All` or `Clients.Others`
- Using `ConnectionId` as a stable user identifier or assuming circuit disposal equals logout

## Best used for

SignalR, Blazor Server, Blazor Web App, real-time applications, persistent connection scenarios.

## Primary references

- ASP.NET Core server-side and Blazor Web App additional security scenarios: https://learn.microsoft.com/en-us/aspnet/core/blazor/security/additional-scenarios?view=aspnetcore-10.0
- ASP.NET Core Blazor authentication and authorization: https://learn.microsoft.com/en-us/aspnet/core/blazor/security/?view=aspnetcore-10.0
- ASP.NET Core SignalR security: https://learn.microsoft.com/en-us/aspnet/core/signalr/security?view=aspnetcore-10.0

## Review cues

- [ ] Hub methods that perform privileged operations have method-level `[Authorize(Policy = "...")]`
- [ ] All user identity is derived from `Context.UserIdentifier`, not client-supplied parameters
- [ ] `access_token` query string parameter is redacted from server and infrastructure logs
- [ ] `JwtBearerEvents.OnMessageReceived` extracts the token from query string for hub paths
- [ ] Group membership is validated server-side before `Groups.AddToGroupAsync`
- [ ] `IHubContext<T>` calls target specific users or groups, never `Clients.All` for sensitive data
- [ ] Circuit-scoped services do not cache stale `ClaimsPrincipal` across reconnects
- [ ] `AuthenticationStateProvider` is used for current identity, not a cached copy
- [ ] Connection ID is not used as a user identifier or authorization principal
- [ ] Token lifetime is reviewed relative to expected connection duration

## Good looks like

- Every hub method enforces its own authorization policy independently
- `Context.UserIdentifier` is the sole source of caller identity in hub methods
- Token query-string values are filtered from all log output and monitoring
- Group join operations validate membership through a server-side authorization service
- `IHubContext<T>` messages are scoped to the intended recipient only
- Circuit-scoped services resolve identity through `AuthenticationStateProvider` on each access
- Reconnection triggers re-authentication; stale circuits are not implicitly trusted

## Common findings / likely remediations

| Finding | Remediation |
|---------|-------------|
| Hub method lacks per-invocation authorization | Add `[Authorize(Policy = "...")]` to the hub method |
| Client-supplied userId trusted in hub method | Replace with `Context.UserIdentifier` |
| Token visible in server logs | Redact `access_token` query parameter in logging configuration |
| Arbitrary group join without validation | Add server-side membership check before `Groups.AddToGroupAsync` |
| Sensitive data sent to `Clients.All` | Scope to `Clients.User(id)` or `Clients.Group(name)` |
| Stale claims cached in circuit service | Use `AuthenticationStateProvider.GetAuthenticationStateAsync()` |
| Connection ID used as user identity | Replace with `Context.UserIdentifier` from authenticated claims |
| No re-auth on reconnect | Validate token and identity on each new connection establishment |
