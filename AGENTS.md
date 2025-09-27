# Repository Guidelines

## Project Structure & Module Organization
Rails code lives in `app/` (models, controllers, views, `app/javascript` packs, and Stimulus controllers). Shared helpers, decorators, and background jobs sit in `lib/` and `app/services/`. Configuration files stay in `config/`, while `db/` holds migrations and fixtures used by setup scripts. Static assets are served from `public/`, and reusable binaries (including `bin/dev`, `bin/rubocop`, `bin/brakeman`) live in `bin/`. Tests reside in `test/` with fixtures under `test/fixtures/`.

## Build, Test, and Development Commands
Run `bundle install && yarn install` once per clone. Use `bin/rails db:migrate` and `RAILS_ENV=development bin/rails db:fixtures:load` to prime data. Start the full stack with `bin/dev`; fall back to `bin/rails server` when you only need the Rails app. Execute `bin/rails test` for the full suite or scope with `bin/rails test test/models/user_test.rb`. Lint Ruby with `bin/rubocop`, scan for security issues via `bin/brakeman`, and compile front-end assets on demand with `bin/shakapacker`.

## Coding Style & Naming Conventions
Follow community Ruby style: 2-space indentation, `CamelCase` classes, and snake_case filenames. Keep controllers, jobs, and mailers under `app/` folders that mirror Rails defaults; match Stimulus controllers to their DOM data-controller names (e.g., `user_form_controller.js`). Use RuboCop’s autocorrect before submitting. Prefer service objects in `app/services/` for multi-step workflows and keep view logic in presenters/helpers.

## Testing Guidelines
We rely on Minitest in `test/`; name files `*_test.rb` and classes `SomethingTest`. Use fixtures from `test/fixtures/` and create factories only when fixtures fall short. Run `bin/rails test` locally before opening a PR and re-run focused tests after migrations. Target coverage parity with touched lines and document gaps in the PR when unavoidable.

## Commit & Pull Request Guidelines
Write commit subjects in the imperative mood (e.g., `Upgrade shakapacker`), mirroring the existing Git history. Group unrelated updates into separate commits. Pull requests should include: a concise summary, references to tickets, screenshots for UI-facing work, and a note about migrations or data loads. Include the commands you ran (`bin/rails test`, `bin/rubocop`, etc.) to ease review, and request review from the owning team when touching shared modules.

## Security & Configuration Tips
Never commit secrets; store credentials with `bin/rails credentials:edit` and keep `config/master.key` outside version control. When importing sample data, follow the steps in `README.md` to reset and populate `thape_pp_dev`. For front-end hot reloading, set `hmr: true` in `config/shakapacker.yml` as described in the README.
