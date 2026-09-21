require "test_helper"

class EvaluationUserCapabilityPolicyTest < ActiveSupport::TestCase
  setup do
    @hr_user = users(:user_fangzixue)
    @evaluation = evaluation_user_capabilities(:euc_pp6)
    @job_role = user_job_roles(:ujr_3647)
    @hr_user.hr_user_managed_companies.create!(managed_company: @evaluation.company)
  end

  test "HR can view and print historical evaluations after an employee transfers" do
    @job_role.update!(company: "Another company")

    assert_hr_access
  end

  test "HR can view and print historical evaluations without an active job role" do
    @job_role.update!(is_active: false)

    assert_hr_access
  end

  test "HR can still view and print evaluations for employees currently in a managed company" do
    @evaluation.update!(company: "Previous company")

    assert_hr_access
  end

  test "HR cannot view or print evaluations outside their managed companies" do
    @evaluation.update!(company: "Another company")
    @job_role.update!(company: "Another company")

    assert_no_hr_access
  end

  test "an inactive job role does not grant HR access to an unmanaged historical company" do
    @evaluation.update!(company: "Another company")
    @job_role.update!(is_active: false)

    assert_no_hr_access
  end

  test "unrelated staff cannot view or print historical evaluations" do
    policy = EvaluationUserCapabilityPolicy.new(users(:user_pptest5), @evaluation)

    assert_not policy.show?
    assert_not policy.print?
  end

  private

  def assert_hr_access
    assert EvaluationUserCapabilityPolicy::Scope.new(@hr_user, EvaluationUserCapability).resolve.exists?(@evaluation.id)
    policy = EvaluationUserCapabilityPolicy.new(@hr_user, @evaluation)
    assert policy.show?
    assert policy.print?
  end

  def assert_no_hr_access
    assert_not EvaluationUserCapabilityPolicy::Scope.new(@hr_user, EvaluationUserCapability).resolve.exists?(@evaluation.id)
    policy = EvaluationUserCapabilityPolicy.new(@hr_user, @evaluation)
    assert_not policy.show?
    assert_not policy.print?
  end
end
