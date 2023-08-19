class UsersDatatable < ApplicationDatatable
  def_delegator :@view, :button_to
  def_delegator :@view, :sign_in_as_admin_user_path

  def initialize(params, opts = {})
    @users = opts[:users]
    @current_user = opts[:current_user]
    super
  end

  def view_columns
    @view_columns ||= {
      id: {source: "User.id", searchable: true, cond: :eq},
      email: {source: "User.email", cond: :like},
      chinese_name: {source: "User.chinese_name", searchable: true, cond: :like},
      clerk_code: {source: "User.clerk_code", searchable: true, cond: :like},
      hire_date: {source: "User.hire_date", searchable: false, orderable: true},
      job_role: {source: nil, searchable: false, orderable: false},
      status: {source: nil, searchable: false, orderable: false},
      actions: {source: nil, searchable: false, orderable: false}
    }
  end

  def data
    records.map do |r|
      {
        id: r.id,
        email: "#{r.email}<br />#{r.hire_date} ID:#{r.id}".html_safe,
        chinese_name: r.chinese_name,
        clerk_code: r.clerk_code,
        job_role: render(partial: "datatable/user_job_role", locals: {user: r}, formats: :html),
        status: render(partial: "datatable/user_status", locals: {user: r}, formats: :html),
        actions: render(partial: "datatable/user_action", locals: {user: r}, formats: :html),
        DT_RowId: r.id # This will automagically set the id attribute on the corresponding <tr> in the datatable
      }
    end
  end

  def get_raw_records
    @users
  end
end
