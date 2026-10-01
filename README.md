# a People Performance system

[![build status](https://github.com/thape-cn/pp/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/thape-cn/pp/actions) [![pipeline status](https://git.thape.com.cn/rails/pp/badges/main/pipeline.svg)](https://git.thape.com.cn/rails/pp/-/commits/main)

## How to Start (or Restart) Development?

Traditionally, you would run `bin/setup`, but the following steps will get you started more quickly.

```bash
bin/rails db:migrate
RAILS_ENV=development bin/rails db:fixtures:load
bin/rails server # login as guochunzhong@thape.com.cn / pp_rocks
```

## Development Notes

### Background report exports

All Excel reports and evaluation PDF downloads run in Sidekiq. Apply the migration
with `bin/rails db:migrate` and restart the web and Sidekiq processes when deploying.
For local development, start Redis and run `bundle exec sidekiq` alongside `bin/dev`.
The Sidekiq initializer starts a `reports` capsule with one worker per process to
limit workbook memory use while keeping the default queue available for other jobs.
Set the Sidekiq process's database pool (`RAILS_MAX_THREADS`) to at least its total
worker concurrency (6 with the default 5 workers plus the report worker).

Export requests return a status page immediately. Users can revisit their latest
100 requests through **My exports**, download completed files, and retry failed
requests. Jobs apply the requesting user's current permissions and language.
Generation errors are retried up to three times before the request is marked failed.

Files use the configured Active Storage service and expire after seven days.
The existing Whenever schedule queues daily cleanup; update the crontab on deployment.
Web and worker processes must share the same Active Storage files (the deployment
already links `storage`). PDF workers also need Chrome and access to the app's
printing URL, using the existing printing endpoint's trusted network configuration.

### How to Import the Database

```bash
mysql -u root
DROP DATABASE thape_pp_dev;
CREATE DATABASE thape_pp_dev character set UTF8mb4 collate utf8mb4_0900_ai_ci;
\q
gunzip < mysql_pp_db.sql.gz | mysql -u root thape_pp_dev
```

### Debugging SCSS

Set `shakapacker.yml` hmr to true.

```yml
---
hmr: true
```

### Why should always include "stimulus"?

With webpack 5, the loading sequence is important.

### How to debug in VSCode?

Install `Ruby LSP` by Shopify and `VSCode rdbg Ruby Debugger` by KoichiSasada.

Ensure that only one version of the debug gem is installed as a default gem. If not, uninstall it first:

```bash
gem uninstall -i /opt/homebrew/Cellar/ruby/3.2.2/lib/ruby/gems/3.2.0 debug
gem install debug --default
```
