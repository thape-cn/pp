# Repository Guidelines

## Project Structure & Module Organization
- Rails 8 app. Core code in `app/` with namespaced controllers (`admin/`, `hr/`, `cp/`, `staff/`), matching views/policies/services/jobs/mailers; keep features in the right namespace.
- Frontend entrypoints in `app/javascript/packs/`; shared Stimulus controllers in `app/javascript/controllers/`; lazy controllers in `app/javascript/lazy_controllers/`; React components in `app/javascript/react/`. DataTables live in `app/datatables/`; background jobs in `app/sidekiq/`.
- Routes split by role in `config/routes*.rb`. Schema/migrations in `db/`; fixtures in `test/fixtures/`; tests (model/system/mailers) in `test/`. Use `bin/` shims for rails/rake/shakapacker/pnpm/rubocop/brakeman.

## Build, Test, and Development Commands
- Install & prepare: `bin/setup` or `bundle install`, `bin/pnpm install`, `bin/rails db:migrate`, `RAILS_ENV=development bin/rails db:fixtures:load`.
- Run app: `bin/dev` for Rails + Shakapacker, or `bin/rails server` with `bin/shakapacker-dev-server`.
- Assets: `bin/shakapacker` builds production packs.
- Tests: `bin/rails test` (non-system), `bin/rails test:system` (Capybara), `bin/rails test:db` (reset then run). Lint/security: `bin/rubocop` (StandardRB) and `bin/brakeman`.

## Coding Style & Naming Conventions
- StandardRB defaults: 2 spaces, double quotes, idiomatic Rails; keep controllers thin and push logic to services/models.
- Class names by role (`SomethingDatatable`, `SomethingJob`, `SomethingPolicy`); place jobs in `app/sidekiq/`, policies in `app/policies/`.
- Stimulus controllers named `*_controller.js` (kebab filenames, camelCase values); React components PascalCase under `app/javascript/react/`; packs should stay small and feature-scoped.
- Authorize controllers with Pundit (`authorize`, `policy_scope`); prefer PORO services over callbacks.

## Testing Guidelines
- Add Minitest coverage with each change; use fixtures or build records inline. Pair model tests with system tests for user-facing flows.
- Run targeted files via `bin/rails test path/to/file_test.rb`; use `bin/rails test:system` when touching Stimulus/React screens.
- Keep tests deterministic: freeze time for time-based assertions and stub external calls.

### System Tests and Restricted Cloud Environments
- `bin/rake` and `bin/rails test` exclude system tests. Run `bin/rails test:system` separately; a green default CI run does not establish browser-test coverage.
- With dependencies, the test database, and Chrome/Chromium plus a compatible driver available, use `RAILS_ENV=test HEADLESS=1 SE_AVOID_STATS=true PARALLEL_WORKERS=1 bin/rails test:system`. `SE_AVOID_STATS=true` disables Selenium Manager telemetry; serial execution avoids Rails parallel workers' Unix-socket requirement.
- In the dot cloud command environment checked on 2026-10-04, even an approved elevated execution retry could create TCP sockets but not Unix sockets (`AF_UNIX` returned `EPERM`). Chromium exited at `process_singleton_posix.cc` before creating a browser session. This is an execution-environment restriction, not evidence of an application assertion failure or a general Linux/Chromium incompatibility.
- Changing gems or temporary directories does not fix a denied socket-creation syscall. Use an execution environment that permits the browser's required local sockets; do not disable the browser sandbox or weaken security controls. Report browser startup errors separately from failed application assertions.
- Reference verification: on 2026-10-04, commit `64c427e932f4a0694d20ce50bed955525c78e924` passed all 7 system tests with 62 assertions in 12.46 seconds on a MacBook Pro. This records that revision's result, not a guarantee for later changes.

## Commit & Pull Request Guidelines
- Commit messages match repo style: short imperative summaries (`Add rorvswild monitor`). Keep concerns small.
- PRs should note scope, linked issue, tests run (`bin/rails test`, `bin/rubocop`), screenshots for UI, and call out migrations/backfills/ops steps.

## Security & Configuration Tips
- Keep secrets in Rails credentials or env vars; do not commit dumps or production configs. Default dev login lives in `README.md`.
- Leave Shakapacker HMR (`config/shakapacker.yml`) on for local dev only.
