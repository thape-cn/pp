class Initiation
  def self.clean_pp_test_company_evaluation_data(company_evaluation)
    company_evaluation_template_ids = company_evaluation.company_evaluation_templates.pluck(:id)
    pp_test_user_ids = User.where('email LIKE "pptest%@thape.com.cn"').pluck(:id)
    EvaluationUserCapability.where(company_evaluation_template_id: company_evaluation_template_ids,
      user_id: pp_test_user_ids).each do |euc|
      euc.destroy
    end
    JobRoleEvaluationPerformance.where(company_evaluation_id: company_evaluation.id,
      user_id: pp_test_user_ids).each do |jrep|
      jrep.destroy
    end
    CalibrationSessionUser.where(user_id: pp_test_user_ids).each do |csu|
      next if csu.evaluation_user_capability.present?

      csu.destroy
    end
    calibration_template_ids = CalibrationTemplate.where(company_evaluation_template_id: company_evaluation_template_ids).pluck(:id)
    CalibrationSession.where(calibration_template_id: calibration_template_ids).each do |session|
      next if session.calibration_session_users.present?

      session.destroy
    end
  end
end
