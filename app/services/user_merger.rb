class UserMerger
  def self.do_merge(main_user_id, to_remove_user_ids)
    to_remove_user_ids = [to_remove_user_ids] unless to_remove_user_ids.is_a?(Array)

    ArchivedEvaluationUserCapability.where(user_id: to_remove_user_ids).update_all(user_id: main_user_id)
    ArchivedEvaluationUserCapability.where(manager_user_id: to_remove_user_ids).update_all(manager_user_id: main_user_id)
    CalibrationSessionJudge.where(judge_id: to_remove_user_ids).update_all(judge_id: main_user_id)
    CalibrationSessionUser.where(user_id: to_remove_user_ids).update_all(user_id: main_user_id)
    CalibrationSession.where(owner_id: to_remove_user_ids).update_all(owner_id: main_user_id)
    EucFormStatusHistory.where(user_id: to_remove_user_ids).update_all(user_id: main_user_id)
    EvaluationUserCapability.where(user_id: to_remove_user_ids).update_all(user_id: main_user_id)
    EvaluationUserCapability.where(manager_user_id: to_remove_user_ids).update_all(manager_user_id: main_user_id)
    HRUserManagedCompany.where(user_id: to_remove_user_ids).update_all(user_id: main_user_id)
    HrbpUserManagedDepartment.where(user_id: to_remove_user_ids).update_all(user_id: main_user_id)
    JobRoleEvaluationPerformance.where(user_id: to_remove_user_ids).update_all(user_id: main_user_id)
    UserJobRole.where(user_id: to_remove_user_ids).update_all(user_id: main_user_id)
    UserRole.where(user_id: to_remove_user_ids).update_all(user_id: main_user_id)

    to_remove_user_ids.each do |to_remove_user_id|
      to_remove_user = User.find to_remove_user_id
      to_remove_user.destroy
    end
  end
end
