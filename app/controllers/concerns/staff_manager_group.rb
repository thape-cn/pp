module StaffManagerGroup
  extend ActiveSupport::Concern

  private

  def staff_group(evaluation_user_capabilities)
    evaluation_user_capabilities.group_by do |euc|
      "#{euc.group_of_staff_work_load}#{euc.group_of_staff_work_quality_and_work_attitude}"
    end
  end

  def manager_group(evaluation_user_capabilities)
    evaluation_user_capabilities.group_by do |euc|
      "#{euc.group_of_manager_performance}#{euc.group_of_manager_capability}"
    end
  end
end
