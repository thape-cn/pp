class PendingStaffConfirmReminder
  def self.sent_wechat_message(open_company_evaluation_ids)
    company_evaluation_template_ids = CompanyEvaluationTemplate
      .where(company_evaluation_id: open_company_evaluation_ids)
      .pluck(:id)
    EvaluationUserCapability.where(form_status: "hr_review_completed", company_evaluation_template_id: company_evaluation_template_ids).each do |euc|
      wechat_user_id = euc.user.wecom_id.present? ? euc.user.wecom_id : euc.user.email.split("@")[0]
      StaffNeedConfirmRemindJob.perform_async(wechat_user_id, euc.id)
    end
  end
end
