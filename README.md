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

### performance data design note

一个人有多个 job role （基准岗位，中间表user_job_roles），user_job_roles中记录 STCODE，manager_userid，company， department， title ，然后user_job_roles和 工作角色（job role）多对一，考评角色（Evaluation roles）和工作角色（job role）是一对多关系，需手工设置，考评角色（Evaluation roles）中配置考评表单的能力相关的子表单出现与否（在填绩效考评表时）

一个人有多个job role，要填多张绩效考评表，工作角色（job role）中记录job_level，job code， job family。

* 配置UI：考评角色（Evaluation roles）对工作角色（job role）的配置（一对多）
* 角色能力UI：考评角色（Evaluation roles）对能力的配置（多对多）

用户的业绩只和公司的每一次考评相关，和模版无关，当然需要在模版里面有业绩比例的时候，显示这些业绩比例。

### 总分计算公式

工作能力上级评分 = 工作量评分*50% + 工作质量评分*35% + 工作态度评分*15%（模版可配置）
员工层总分 = 工作能力评分*100% + 专业能力评分*0% + 管理能力评分*0% + 业绩评分折算*0%
主管层总分 = 工作能力评分*0% + 专业能力评分*35% + 管理能力评分*15% + 业绩评分折算*50%

### 表单状态

```yml
---
form_status:
  initial: "初始化完成"
  self_assessment_done: "员工自评完成"
  manager_scored: "直属上级评价完成"
  department_calibrated: "部门经理校准完成"
  hr_review_completed: "HR 校验完成"
  data_locked: "数据锁定"
```

更新表单状态请使用`update_form_status_to`，这个方法才会生成对于的表单状态改动历史。
