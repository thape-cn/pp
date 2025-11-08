# People Performance (PP) System - Repository Guidelines

## Project Overview

This is a People Performance management system built with Ruby on Rails 8.0.2 and modern JavaScript tooling. The system provides comprehensive HR functionality including employee evaluations, calibrations, performance reviews, and administrative capabilities. It uses a modular architecture with role-based access control for different user types (admin, corp_president, hr_staff, staff).

## Technology Stack

- **Backend**: Ruby 3.2+, Rails 8.0.2, SQLite3 (development), MySQL (production)
- **Frontend**: React 18.3.1, Stimulus.js, CoreUI 4.3.2, Bootstrap 5, Chart.js
- **Build System**: Shakapacker 8.4.0 (Webpack 5), Babel, Sass
- **Background Jobs**: Sidekiq
- **Authentication**: Devise with OmniAuth OpenID Connect
- **Authorization**: Pundit

## Project Structure & Module Organization

Rails code lives in `app/` with the following organization:
- **Controllers**: Role-based namespaces (`admin/`, `cp/`, `hr/`, `staff/`, `accounts/`)
- **Models**: Domain models for HR functionality (evaluations, calibrations, capabilities, users)
- **Views**: Template organization matching controller structure
- **JavaScript**: Modern packs in `app/javascript/packs/` with Stimulus controllers and React components
- **Stimulus Controllers**: Match DOM data-controller names (e.g., `user_form_controller.js`)
- **Services**: Business logic in `app/services/` (initiation services, reminders)
- **Policies**: Authorization logic in `app/policies/`
- **Datatables**: Custom DataTables implementations in `app/datatables/`

Shared helpers and utilities sit in `lib/`. Configuration files stay in `config/`, while `db/` holds migrations. Static assets are served from `public/`, and reusable binaries live in `bin/`. Tests reside in `test/` with fixtures under `test/fixtures/`.

## Build, Test, and Development Commands
Run `bundle install && pnpm install` once per clone. Use `bin/rails db:migrate` and `RAILS_ENV=development bin/rails db:fixtures:load` to prime data. Start the full stack with `bin/dev`; fall back to `bin/rails server` when you only need the Rails app. Execute `bin/rails test` for the full suite or scope with `bin/rails test test/models/user_test.rb`. Lint Ruby with `bin/rubocop`, scan for security issues via `bin/brakeman`, and compile front-end assets on demand with `bin/shakapacker`.

## Coding Style & Naming Conventions
Follow community Ruby style: 2-space indentation, `CamelCase` classes, and snake_case filenames. Keep controllers, jobs, and mailers under `app/` folders that mirror Rails defaults; match Stimulus controllers to their DOM data-controller names (e.g., `user_form_controller.js`). Use RuboCop’s autocorrect before submitting. Prefer service objects in `app/services/` for multi-step workflows and keep view logic in presenters/helpers.

## Testing Guidelines
We rely on Minitest in `test/`; name files `*_test.rb` and classes `SomethingTest`. Use fixtures from `test/fixtures/` and create factories only when fixtures fall short. Run `bin/rails test` locally before opening a PR and re-run focused tests after migrations. Target coverage parity with touched lines and document gaps in the PR when unavoidable.

## Internationalization

- Supported locales: English (`en`) and Chinese (`zh-CN`)
- Translation files in `config/locales/`

## Security & Configuration Tips
Never commit secrets; store credentials with `bin/rails credentials:edit` and keep `config/master.key` outside version control. When importing sample data, follow the steps in `README.md` to reset and populate `thape_pp_dev`. For front-end hot reloading, set `hmr: true` in `config/shakapacker.yml` as described in the README.

## Development Notes

**Webpack Loading Order:**
With Webpack 5, loading sequence is important - always include Stimulus as needed

**Database Notes:**
- Test database reset on each test run
