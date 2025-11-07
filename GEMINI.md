# GEMINI.md

This file provides guidance to Gemini when working with code in this repository.

## Overview

This is a Ruby on Rails 8 application for a **People Performance system** - an enterprise HR performance evaluation platform. It manages employee evaluations, calibration sessions, and performance reviews across different organizational roles.

## Project Stack

- **Backend**: Ruby on Rails 8.0.2, Ruby 3.2
- **Frontend**: Shakapacker (Webpack 5), Stimulus, React 18, CoreUI
- **Database**: SQLite (development), MySQL (production)
- **Authentication**: Devise with OmniAuth OpenID Connect (SSO)
- **Authorization**: Pundit with role-based access
- **Background Jobs**: Sidekiq
- **UI Components**: CoreUI, DataTables (server-side), Selectize
- **Testing**: Minitest, Capybara, Selenium
- **Code Quality**: StandardRB (RuboCop), Ruby LSP
- **Package Manager**: pnpm for Node packages, Bundler for Ruby gems

## Common Development Commands

### Initial Setup

```bash
# Full setup (installs dependencies, sets up database, loads fixtures, starts dev server)
bin/setup

# Or step by step:
bundle install
bin/pnpm install
bin/rails db:prepare
RAILS_ENV=development bin/rails db:fixtures:load
bin/dev
```

### Running the Application

```bash
# Start development server with webpack dev server
bin/dev

# Or separately:
bin/rails server
bin/shakapacker-dev-server
```

### Database Operations

```bash
bin/rails db:migrate
bin/rails db:fixtures:load
bin/rails db:rollback STEP=1
```

### Testing

```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/models/user_test.rb

# Run tests with database reset
bin/rails test:db

# System tests (Capybara)
bin/rails test:system
```

### Code Quality

```bash
# Lint and fix code
bin/rubocop -A

# Security scanning
bin/brakeman
```

### Frontend Assets

```bash
# Compile assets for production
bin/shakapacker

# Install JavaScript dependencies
bin/pnpm install
```

## Architecture & Organization

### Namespaced Controllers

The application uses **four main namespaces** with dedicated base controllers for role-based access:

1. **Admin** (`app/controllers/admin/base_controller.rb`):
   - Requires admin role via `require_admin!`
   - Manages system-wide settings, templates, and configurations

2. **HR** (`app/controllers/hr/base_controller.rb`):
   - Requires HR staff via `require_hr_staff!`
   - Manages evaluation processes, calibration sessions, and HR workflows

3. **CP (Corp President)** (`app/controllers/cp/base_controller.rb`):
   - Requires corp president via `require_corp_president!`
   - Executive-level oversight and approvals

4. **Staff** (`app/controllers/staff/base_controller.rb`):
   - Requires authenticated user via `require_user!`
   - Employee self-assessment and review participation

### Routing Structure

Routes are organized into separate files:
- Main routes: `config/routes.rb`
- Admin routes: `config/routes/admin.rb`
- HR routes: `config/routes/hr.rb`
- CP routes: `config/routes/cp.rb`
- Staff routes: `config/routes/staff.rb`

Each namespace file uses `draw :namespace` to load route definitions.

### Key Models & Domain Concepts

- **User**: Central user model with Devise authentication and role checks
  - Role methods: `admin?`, `hr_staff?`, `corp_president?`, `secretary?`, `hr_bp?`
  - Associated with roles, job roles, evaluation capabilities

- **EvaluationUserCapability**: Core model for performance evaluations
- **CalibrationSession**: Calibration process management
- **JobRole**: Employee job roles and capabilities
- **CompanyEvaluationTemplate**: Evaluation framework templates
- **CalibrationSessionUser/Judge**: Participants in calibration sessions

### Frontend Architecture

**Shakapacker Packs** (`app/javascript/packs/`):
- `application.js` - Global utilities (LocalTime, Simplebar)
- `stimulus.js` - Registers Stimulus controllers
- `datatables.js` - DataTables initialization
- `mark-scores.js` - React component for scoring interface
- `calibration-panel.js` - React component for calibration UI
- `calibration-table.js` - React component for calibration table

**Stimulus Controllers**:
- Global controllers in `app/javascript/controllers/`
- Lazy-loaded controllers in `app/javascript/lazy_controllers/` for feature-specific functionality

**React Components**:
- Mounted by page-specific packs using React 18 `createRoot`
- Target specific DOM IDs (e.g., `staff-mark`, `calibration-panel`)
- Components live in `app/javascript/react/`

**CoreUI Integration**:
- CoreUI Pro used for UI components, tooltips, and carousels
- Initialized in `packs/stimulus.js`

### DataTables (Server-Side Processing)

Ruby Datatables in `app/datatables/`:
- Base class: `application_datatable.rb`
- Examples: `users_datatable.rb`, `capability_datatable.rb`

Frontend:
- Stimulus controller in `lazy_controllers/datatables.js`
- Include `data-controller="datatables"` in views
- Pass configuration via data attributes

### Background Jobs (Sidekiq)

Jobs located in `app/sidekiq/`:
- Email reminders (self-assessment, manager scoring, HR review)
- WeChat notifications
- Data import jobs (evaluations, performance, calibration sessions)
- Archive and cleanup jobs

Jobs handle workflow automation and notifications across the evaluation lifecycle.

### Authentication & Authorization

**Authentication**:
- Devise configured in `config/routes.rb` with custom controllers
- OmniAuth OpenID Connect for SSO
- Global authentication via `before_action :authenticate_user!`

**Authorization (Pundit)**:
- Included in `application_controller.rb`
- Base policy: `app/policies/application_policy.rb`
- Domain-specific policies in `app/policies/`
- Use `authorize(record)` in member actions
- Use `policy_scope(Model)` in collection actions

### Custom Rake Tasks

- `import.rake` - Import Excel files for evaluations, performance, and calibration
- `maintain.rake` - Data maintenance and cleanup
- `edoc2.rake` - EDOC2 document integration

## Development Notes from README

### Debugging SCSS
Set `hmr: true` in `config/shakapacker.yml` for hot module replacement.

### VSCode Debugging
Install:
- Ruby LSP by Shopify
- VSCode rdbg Ruby Debugger by KoichiSasada

Ensure only one version of the debug gem is installed:
```bash
gem uninstall -i /opt/homebrew/Cellar/ruby/3.2.2/lib/ruby/gems/3.2.0 debug
gem install debug --default
```

### Database Import (Production)
```bash
mysql -u root
DROP DATABASE thape_pp_dev;
CREATE DATABASE thape_pp_dev character set UTF8mb4 collate utf8mb4_0900_ai_ci;
\q
gunzip < mysql_pp_db.sql.gz | mysql -u root thape_pp_dev
```

### Default Login
`guochunzhong@thape.com.cn / pp_rocks`
