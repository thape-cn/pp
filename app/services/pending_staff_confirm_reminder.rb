class PendingStaffConfirmReminder
  def self.sent_wechat_message(open_company_evaluation_ids)
    company_evaluation_template_ids = CompanyEvaluationTemplate
      .where(company_evaluation_id: open_company_evaluation_ids)
      .pluck(:id)
    EvaluationUserCapability.where(form_status: "hr_review_completed", company_evaluation_template_id: company_evaluation_template_ids).each do |euc|
      company_evaluation_id = euc.company_evaluation_template.company_evaluation_id
      clerk_code = euc.user.clerk_code
      StaffNeedConfirmRemindWecomJob.perform_async(company_evaluation_id, clerk_code)
    end
  end
end
