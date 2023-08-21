class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :check_brower, if: -> { request.format.html? }

  def index
    return redirect_to admin_root_path if current_user&.admin?
    return redirect_to hr_root_path if current_user&.hr_staff?
    redirect_to staff_root_path if current_user.present?
  end

  protected

  def set_page_layout_data
    super
    @skip_title = true
  end
end
