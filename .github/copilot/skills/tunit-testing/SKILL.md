---
name: "tunit-testing"
description: "TUnit framework on Microsoft Testing Platform — how to write, run, and debug tests in .NET projects using TUnit instead of xUnit/NUnit/MSTest"
---

# TUnit Testing — Microsoft Testing Platform

## Context

This project uses **TUnit** on **.NET 10 native Microsoft Testing Platform (MTP) mode**. Agents consistently get this wrong by defaulting to xUnit/NUnit patterns or using VSTest-style CLI flags. This skill prevents those mistakes.

## Key Facts

- **Framework:** TUnit (Apache 2.0 licensed), NOT xUnit, NUnit, or MSTest
- **Platform:** Microsoft Testing Platform (MTP), NOT VSTest
- **Package:** `TUnit` via NuGet
- **Run mode:** .NET 10 native MTP mode via `global.json` configuration
- **Test attribute:** `[Test]` — NOT `[Fact]`, `[Theory]`, `[TestMethod]`
- **Assertions:** Async — `await Assert.That(value).IsEqualTo(expected);`

## Running Tests

### .NET 10 Native MTP Mode

The project configures MTP in `global.json`:

```json
{
  "sdk": { "version": "10.0.100", "rollForward": "latestMinor" },
  "test": { "runner": "Microsoft.Testing.Platform" }
}
```

With native MTP mode:
- Use `dotnet test` directly — it routes through MTP, not VSTest
- The `TestingPlatformDotnetTestSupport` MSBuild property is **NOT needed** and must NOT be set
- The extra `--` separator between `dotnet test` args and MTP args is **no longer required**

### CLI Commands

```bash
# Run all tests
dotnet test

# Run tests in Release config
dotnet test -c Release

# Run tests with TRX report (CI)
dotnet test -c Release --no-build --report-trx --report-trx-filename results.trx

# Run tests with code coverage (CI)
dotnet test -c Release --no-build --coverage

# Run a specific test project
dotnet test tests/MyProject.Tests/
```

### VSTest Flags That Will FAIL

These are VSTest flags. They produce exit code 5 ("Zero tests ran") with MTP:

| Purpose | Wrong (VSTest) | Correct (MTP) |
|---|---|---|
| TRX report | `--logger "trx;LogFileName=results.trx"` | `--report-trx --report-trx-filename results.trx` |
| Code coverage | `--collect:"XPlat Code Coverage"` | `--coverage` |

## Writing Tests

### Test Class Structure

```csharp
using TUnit.Core;

public class MyServiceTests
{
    [Test]
    public async Task DoSomething_WhenValid_ReturnsExpected()
    {
        // Arrange
        var service = new MyService();

        // Act
        var result = service.DoSomething("input");

        // Assert
        await Assert.That(result).IsNotNull();
        await Assert.That(result.Name).IsEqualTo("expected");
    }
}
```

### Assertions — ALL Are Async

TUnit assertions use `await Assert.That(...)`. Every assertion must be awaited:

```csharp
// Correct — async assertions
await Assert.That(result).IsNotNull();
await Assert.That(result.Name).IsEqualTo("Test");
await Assert.That(items).HasCount().EqualTo(3);
await Assert.That(items).Contains("expected-item");
await Assert.That(items).DoesNotContain("excluded");
await Assert.That(action).ThrowsException().OfType<NotFoundException>();

// Wrong — xUnit/NUnit/MSTest patterns
Assert.NotNull(result);            // xUnit
Assert.AreEqual("Test", result);   // NUnit/MSTest
Assert.Equal("Test", result);      // xUnit
Assert.Throws<Exception>(() => {}); // xUnit sync
```

### Test Attributes

```csharp
[Test]                              // Standard test
[Test, Skip("Reason")]              // Skip a test

[Test]
[Arguments("input1", "expected1")]  // Parameterised test
[Arguments("input2", "expected2")]
public async Task MyTest(string input, string expected) { }

[Before(Test)]                      // Runs before each test
public async Task Setup() { }

[After(Test)]                       // Runs after each test
public async Task Teardown() { }

[Before(Class)]                     // Runs once before all tests in class
public static async Task ClassSetup() { }
```

### TUnit vs xUnit/NUnit Mapping

| Concept | xUnit | NUnit | TUnit |
|---------|-------|-------|-------|
| Test method | `[Fact]` | `[Test]` | `[Test]` |
| Parameterised | `[Theory]` + `[InlineData]` | `[TestCase]` | `[Test]` + `[Arguments]` |
| Setup | Constructor | `[SetUp]` | `[Before(Test)]` |
| Teardown | `IDisposable` | `[TearDown]` | `[After(Test)]` |
| Class setup | `IClassFixture<T>` | `[OneTimeSetUp]` | `[Before(Class)]` (static) |
| Assert equal | `Assert.Equal(e, a)` | `Assert.AreEqual(e, a)` | `await Assert.That(a).IsEqualTo(e)` |
| Assert throws | `Assert.Throws<T>()` | `Assert.Throws<T>()` | `await Assert.That(act).ThrowsException()` |
| Assert null | `Assert.Null(x)` | `Assert.IsNull(x)` | `await Assert.That(x).IsNull()` |
| Assert true | `Assert.True(x)` | `Assert.IsTrue(x)` | `await Assert.That(x).IsTrue()` |
| Collection | `Assert.Contains(item, col)` | `CollectionAssert.Contains(col, item)` | `await Assert.That(col).Contains(item)` |

### Integration Tests with WebApplicationFactory

When using `WebApplicationFactory`, remove `IHostedService` implementations that connect to real infrastructure:

```csharp
public class ApiTestFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Remove hosted services that hit real infra
            var descriptor = services.FirstOrDefault(
                d => d.ServiceType == typeof(IHostedService)
                  && d.ImplementationType == typeof(SomeInitializer));
            if (descriptor != null)
                services.Remove(descriptor);
        });
    }
}
```

## Common Agent Mistakes

1. **Using `dotnet test --logger "trx"`** — VSTest syntax. Use `--report-trx` instead.
2. **Writing `Assert.Equal()`** — xUnit. Use `await Assert.That(actual).IsEqualTo(expected)`.
3. **Using `[Fact]` or `[Theory]`** — xUnit. Use `[Test]` and `[Arguments]`.
4. **Using `[InlineData]`** — xUnit. Use `[Arguments]`.
5. **Forgetting to `await` assertions** — TUnit assertions are async. Missing `await` means the assertion doesn't execute.
6. **Setting `TestingPlatformDotnetTestSupport`** — Not needed in .NET 10 native MTP mode.
7. **Using `IClassFixture<T>` or constructor injection** — xUnit. Use `[Before(Class)]` for one-time setup.

## References

- TUnit documentation: https://tunit.dev/docs/intro
- TUnit GitHub: https://github.com/thomhurst/TUnit
- Microsoft Testing Platform: https://learn.microsoft.com/dotnet/core/testing/unit-testing-with-dotnet-test
