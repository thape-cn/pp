class HrbpUserManagedDepartment < ApplicationRecord
  belongs_to :user

  def self.hrbp_by_dept_code
    @_hrbp_by_dept_code ||= select("user_id, managed_dept_code")
      .where(auto_generated: true)
      .group_by(&:managed_dept_code)
  end
end
