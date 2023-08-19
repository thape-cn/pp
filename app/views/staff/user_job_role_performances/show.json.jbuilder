json.obj_name "#{@user_job_role_performance.user.chinese_name}的#{@user_job_role_performance.obj_name}"
json.obj_metric markdown(@user_job_role_performance.obj_metric)
json.close I18n.t("form.close")
