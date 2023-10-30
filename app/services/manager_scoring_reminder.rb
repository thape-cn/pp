# frozen_string_literal: true

class ManagerScoringReminder
  def self.need_sending_wechat_message?(evaluation_user_capability)
    current_company_evaluation = evaluation_user_capability.company_evaluation_template.company_evaluation
    current_manager_user_id = evaluation_user_capability.manager_user_id
    all_reporting_eucs = EvaluationUserCapability.where(manager_user_id: current_manager_user_id,
      company_evaluation_template_id: current_company_evaluation.company_evaluation_templates.pluck(:id))
    still_need_self_assessment_eucs_remainding = all_reporting_eucs.any? { |euc| euc.form_status == "initial" }
    still_need_self_assessment_eucs_remainding ? false : true
  end

  def self.send_wechat_message(manager_user)
    wecom_id = manager_user.wecom_id.present? ? manager_user.wecom_id : manager_user.email.split("@")[0]
    ManagerNeedScoringRemindJob.perform_async(wecom_id)
  end
end
