# a People Performance system

[![Build Status](https://github.com/thape-cn/pp/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/thape-cn/pp/actions)

## Development notes

### How to import the DB

```bash
mysql -u root
DROP DATABASE thape_pp_dev;
CREATE DATABASE thape_pp_dev character set UTF8mb4 collate utf8mb4_0900_ai_ci;
\q
gunzip < mysql_pp_db.sql.gz | mysql -u root thape_pp_dev
```

### When you want to debug the SCSS

Set `shakapacker.yml` hmr to true.

```yml
---
hmr: true
```

### Why should always include "stimulus"

Because using webpack 5, the loading sequence do matter.

### How to debug in VSCode?

Install `Ruby LSP` by Shopify and `VSCode rdbg Ruby Debugger` by KoichiSasada.

Make sure debug only having one version install as default gems, otherwise uninstall first:

```bash
gem uninstall -i /opt/homebrew/Cellar/ruby/3.2.2/lib/ruby/gems/3.2.0 debug
gem install debug --default
```
