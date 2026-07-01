json.obj_name "#{@user_job_role_performance.user.chinese_name}的#{@user_job_role_performance.obj_name}"
json.obj_metric markdown(@user_job_role_performance.obj_metric)
json.obj_result_explain @user_job_role_performance.obj_result_explain
json.obj_result_explain_label I18n.t("evaluation.obj_result_explain")
json.close I18n.t("form.close")
