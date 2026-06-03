# Rust Test Standards

> Apply these standards when writing or reviewing Rust tests.

## Unit Tests

Place unit tests in the same file as the code being tested:

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn function_name_scenario_expected_outcome() {
        // Arrange
        let sut = MyStruct::new();

        // Act
        let result = sut.do_something();

        // Assert
        assert_eq!(result, expected);
    }
}
```

## Integration Tests

Place in `tests/` directory as separate files. These can use the crate's public API only.

## Async Tests

```rust
#[tokio::test]
async fn test_async_operation() {
    let result = some_async_function().await;
    assert!(result.is_ok());
}
```

## Naming

- Test functions: `function_name_scenario_expected_outcome`
- Use descriptive names — the test name is the documentation

## Practices

- Use `assert_eq!`, `assert_ne!`, `assert!` for simple assertions
- Use `assert_matches!` (nightly) or pattern matching for complex cases
- Test both `Ok` and `Err` paths for `Result`-returning functions
- Use `mockall` or manual trait implementations for mocking
- Property-based tests: `proptest` or `quickcheck` for complex invariants
