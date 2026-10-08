---
applies-to: ["**/*.go", "go.mod"]
---

# Go Review Checklist

Repo-specific rules live in the nearest `CLAUDE.md`; open it only to
confirm a specific rule. If a convention isn't written down anywhere, flag
the gap rather than guessing.

## Idioms

- Accept interfaces, return structs. Errors are values, not panics.
- `context.Context` is the first parameter on I/O paths and is propagated,
  not replaced with `context.Background()`.
- `defer` for cleanup; `defer` inside loops is a smell.
- Goroutines have an owner and a stop condition; shared state is guarded.

## Errors

- Wrapped with context: `fmt.Errorf("...: %w", err)`; `errors.Is/As` used
  for checks, not string matching.
- No `_ = f()` dropping an error that matters.
- On a mid-operation failure, earlier changes are rolled back or
  compensated.

## Architecture

- Handler → service → store layering; business logic stays out of handlers.
- New packages match their closest sibling (file layout, error placement,
  test helpers).
- Internal types don't leak across package boundaries.

## Security

- Every endpoint authenticated (health checks excepted) and authorized for
  the caller's tenant/owner.
- User input validated; queries parameterized.
- No secrets in code, logs, or error responses.

## Tests

- Table-driven with named subtests; the changed behavior has a test.
