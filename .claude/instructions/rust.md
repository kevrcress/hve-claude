# Rust Coding Standards

> Apply these standards when writing or reviewing Rust code.

## Project Structure

- Binary crates: `main.rs`; library crates: `lib.rs`
- Keep root-level modules thin — re-export from submodules
- Standard layout: `Cargo.toml`, `src/`, `tests/`

## Cargo.toml

- Stable crates: caret ranges (`version = "1"`)
- Unstable SDKs: pin exact versions
- Release profile: `strip = true`, `lto = true`, `panic = "abort"`

## Naming

| Element | Convention |
|---|---|
| Types / Traits | `PascalCase` |
| Functions / Variables | `snake_case` |
| Constants | `SCREAMING_SNAKE_CASE` |
| Error types | `*Error` suffix |
| Config types | `*Config` suffix |
| Builder types | `*Builder` suffix |

## Error Handling

- Use `thiserror` for library error enums
- Define `type Result<T> = std::result::Result<T, MyError>` in each module
- Avoid `unwrap()` in production code; allowed only in initialization paths with compile-time guarantees
- Use `?` operator consistently for error propagation

## Async

- Runtime: `tokio`
- Race tasks: `tokio::select!`
- Collect results: `tokio::try_join!`
- Async trait methods: `async-trait` crate (Rust 2021 edition)

## Observability

- Logging: `tracing` crate only
- Never use `println!` or `eprintln!` in production
- Distributed tracing: `opentelemetry` when required

## Serialization

- Derive `serde::Serialize` and `serde::Deserialize` for all data types
- Environment variables: define as constants, not magic strings
- Thread-safe globals: `OnceLock`

## Resilience

- Transient failures: `tokio_retry` with exponential backoff

## Documentation

- All public items require `///` doc comments
- Include examples in `///` for public functions
- Document panic conditions and error variants

## Quality Gates

Run before committing:
```bash
cargo clippy -- -D warnings
cargo fmt --check
cargo test
```
