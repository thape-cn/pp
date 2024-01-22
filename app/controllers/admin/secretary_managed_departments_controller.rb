module Admin
  class SecretaryManagedDepartmentsController < BaseController
    after_action :verify_policy_scoped, only: :index
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      @secretary_managed_departments = policy_scope(SecretaryManagedDepartment).includes(:user)
    end

    private

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.admin.header"),
         link: root_path},
        {text: t("layouts.sidebars.admin.account"),
         link: nil}
      ]
    end
  end
end
