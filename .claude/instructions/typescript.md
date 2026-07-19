# TypeScript Coding Standards

> Apply these standards when writing or reviewing TypeScript code.

TypeScript inherits every rule in `javascript.md` (modules, `const` / `let`, `async` / `await`, error handling, naming, equality, package scripts). The sections below add TypeScript-specific rules on top of those.

## Compiler Configuration

- Enable `strict: true` in `tsconfig.json`
- Never disable an individual strict flag to silence an error; fix the type instead
- Also enable `noUncheckedIndexedAccess` and `noImplicitOverride`
- Set `target` and `module` to what the runtime supports; do not downlevel further than needed

## Types on the Public API

- Annotate parameter and return types on every exported function, method, and class member
- Let inference handle local variables; do not annotate what the compiler already knows
- Export the types that describe a module's public surface alongside its values

## Avoiding `any`

- Never use `any` without an inline comment justifying why a precise type is impossible
- Prefer `unknown` for genuinely unknown input, then narrow before use
- Reach for generics instead of `any` to preserve type relationships

## Imports

- Use `import type { ... }` for type-only imports so bundlers can erase them
- Use inline `import { type Foo, bar }` when mixing values and types from one module

## Narrowing over Assertions

- Prefer control-flow narrowing (`typeof`, `instanceof`, `in`, discriminated unions) over `as` assertions
- Reserve `as` for cases the compiler cannot verify; never use `as any` to force a cast
- Avoid the non-null assertion (`!`) where a narrowing guard would work

## Nullability

- With `strict` on, handle `null` and `undefined` explicitly; do not silence them with `!`
- Model optional properties with `?`, not a hand-written `| undefined` union
- Use nullish coalescing (`??`) and optional chaining (`?.`) over manual `&&` guards

## Enums and Literals

- Prefer union string literals (`type Mode = 'read' | 'write'`) over `enum`
- Use `as const` to derive precise literal types from a runtime object
- Use `satisfies` to check a value against a type without widening it

## Type Design

- Prefer `interface` for object shapes that may be extended; use `type` for unions and mapped types
- Make illegal states unrepresentable with discriminated unions
- Mark data that must not mutate as `readonly`
