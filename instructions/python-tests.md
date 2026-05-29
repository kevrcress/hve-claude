# Python Test Standards

> Apply these standards when writing or reviewing Python tests.

## Framework

- Use `pytest` as the test runner
- Use `pytest-asyncio` for async tests
- Use `unittest.mock` or `pytest-mock` for mocking

## Test Structure

```python
def test_function_name_scenario_expected_outcome():
    # Arrange
    sut = MyClass()

    # Act
    result = sut.do_something()

    # Assert
    assert result == expected
```

## Naming

- Test files: `test_module_name.py`
- Test functions: `test_{function}_{scenario}_{outcome}`
- Test classes (when grouping): `TestClassName`

## Practices

- One logical assertion per test (avoid testing multiple unrelated behaviors)
- Use `pytest.mark.parametrize` for data-driven tests
- Use fixtures for shared setup; prefer function scope for isolation
- Mock only external dependencies (HTTP, filesystem, databases)
- Tests must be deterministic — no random data without seeding
- Use `tmp_path` fixture for temporary file operations

## Async Tests

```python
import pytest

@pytest.mark.asyncio
async def test_async_operation():
    result = await some_async_function()
    assert result is not None
```
