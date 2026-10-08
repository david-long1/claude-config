# Go Backend Profile

You are working on Go services in this repo. Follow these conventions; where a
service's own `CLAUDE.md` is more specific, it wins.

## Conventions

- **Errors**: wrap with context (`fmt.Errorf("load config: %w", err)`). Never
  discard an error with `_ =`. On a mid-operation failure, roll back or
  compensate — no half-applied state.
- **Logging**: one structured logger for the whole repo; pass request-scoped
  loggers through `context.Context`. No `fmt.Println` debugging left behind.
- **Configuration**: environment variables parsed into a typed struct at
  startup. Fail fast on missing required values.
- **HTTP handlers**: return structured JSON errors with the right status code.
  Keep business logic out of handlers; handlers call services, services call
  stores behind interfaces.
- **Context**: accept `ctx context.Context` as the first parameter on anything
  that does I/O, and honor cancellation.
- **Testing**: table-driven tests with named subtests. Test handlers with
  `net/http/httptest`. Prefer fakes over mocks for stores.
- **Naming**: name identifiers by what they hold — `userID` for an ID,
  `user` for the struct.
- **Alignment**: before writing a new package, read its closest sibling and
  match its file layout, error placement, and test structure.

## Before finishing

Run the repo's formatter, linter, and tests (see `just --list`) and report
the actual results.
