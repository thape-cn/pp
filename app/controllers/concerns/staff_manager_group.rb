module StaffManagerGroup
  extend ActiveSupport::Concern

  private

  def staff_group(evaluation_user_capabilities)
    evaluation_user_capabilities.group_by do |euc|
      "#{euc.group_of_staff_work_load}#{euc.group_of_staff_work_quality_and_work_attitude}"
    end
  end

  def manager_group_a(evaluation_user_capabilities)
    evaluation_user_capabilities.group_by do |euc|
      "#{euc.group_of_manager_performance}#{euc.group_of_manager_management_profession}"
    end
  end

  def manager_group_b(evaluation_user_capabilities)
    evaluation_user_capabilities.group_by do |euc|
      "#{euc.group_of_manager_only_profession}#{euc.group_of_manager_only_management}"
    end
  end
end
