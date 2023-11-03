# a People Performance system

[![Build Status](https://github.com/thape-cn/pp/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/thape-cn/pp/actions)

## How to Start (or Restart) Development?

Traditionally, you would run `bin/setup`, but the following steps will get you started more quickly.

```bash
bin/rails db:migrate
RAILS_ENV=development bin/rails db:fixtures:load
bin/rails server # login as guochunzhong@thape.com.cn / pp_rocks
```

## Development Notes

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
