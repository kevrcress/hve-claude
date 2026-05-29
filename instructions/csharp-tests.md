# C# Test Standards

> Apply these standards when writing or reviewing C# test projects.

## Project Setup

- Test projects are suffixed `*.Tests` and reference the project under test
- Use xUnit as the default test framework
- Use Moq or NSubstitute for mocking
- Use FluentAssertions for assertions

## Test Structure

```csharp
public class MyServiceTests
{
    [Fact]
    public async Task MethodName_Scenario_ExpectedOutcome()
    {
        // Arrange
        var sut = new MyService();

        // Act
        var result = await sut.DoSomethingAsync();

        // Assert
        result.Should().NotBeNull();
    }
}
```

## Naming

- Test methods: `MethodName_Scenario_ExpectedOutcome` format
- Test classes: `{ClassUnderTest}Tests`

## Practices

- One assertion concept per test (multiple `.Should()` for the same outcome is fine)
- Use `[Theory]` + `[InlineData]` for parameterized tests
- Mock only what is necessary — prefer real implementations for simple dependencies
- Do not test private methods directly; test behavior through the public API
- Each test must be independent — no shared mutable state between tests
