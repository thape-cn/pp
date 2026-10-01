class ReportExportPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end

  def index?
    user.present?
  end

  def show?
    record.user_id == user.id
  end

  def download?
    show?
  end

  def retry?
    show? && record.failed? && create?
  end

  def create?
    return false unless user.present? && record.report_type.in?(ReportExport::GENERATORS.keys)

    case record.report_type
    when /^admin_/ then user.admin?
    when /^hr_/ then user.hr_staff?
    when /^cp_/ then user.corp_president?
    when "staff_progress" then user.hr_bp? || user.secretary?
    when "staff_printing"
      evaluation = EvaluationUserCapability.find_by(id: record.options["evaluation_user_capability_id"])
      evaluation.present? && EvaluationUserCapabilityPolicy.new(user, evaluation).print?
    else true
    end
  end
end
