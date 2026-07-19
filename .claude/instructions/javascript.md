# JavaScript Coding Standards

> Apply these standards when writing or reviewing JavaScript code. Guidance targets plain JavaScript and stays framework-agnostic; it does not assume React, Vue, or any other framework.

## Modules

- Use ES modules (`import` / `export`)
- Use CommonJS (`require` / `module.exports`) only when the repository already standardizes on it
- Prefer named exports for discoverability; at most one default export per module
- Avoid side-effect-only imports except where a polyfill or asset genuinely requires them

## Variables

- Declare with `const` by default; use `let` only when reassignment is required
- Never use `var`
- One binding per declaration; do not chain declarations with commas

## Naming

- Functions and variables: `camelCase`
- Classes and constructors: `PascalCase`
- Module-level constants: `UPPER_SNAKE_CASE`
- Files: `kebab-case.js`

## Async

- Prefer `async` / `await` over raw callbacks or `.then()` chains
- Await inside `try` / `catch`; do not mix `await` with a trailing `.catch()` on the same call
- Run independent operations concurrently with `Promise.all`, not one sequential `await` after another
- Never leave a promise unhandled; every async call is awaited or explicitly handled

## Error Handling

- Throw `Error` objects or subclasses, never strings or plain objects
- No silent `catch`: log, rethrow, or handle every caught error explicitly
- Catch narrowly; do not swallow errors you cannot recover from
- Subclass `Error` for domain errors and set a meaningful `name`

## Equality

- Use `===` and `!==`; never `==` or `!=`
- The one permitted loose check is `value == null` to test for `null` or `undefined` together
- Prefer explicit boolean conditions over relying on truthiness for values that may be `0` or `''`

## Package Scripts

- Define `test`, `lint`, and `build` scripts in `package.json` so contributors run one command
- Pin supported runtimes with an `engines` field
- Commit the lockfile (`package-lock.json`, `pnpm-lock.yaml`, or `yarn.lock`)
- Never hand-edit the lockfile; regenerate it through the package manager

## Formatting

- Format with Prettier and lint with ESLint
- 2-space indentation, semicolons required, single quotes for strings
- No unused variables or imports left in committed code
