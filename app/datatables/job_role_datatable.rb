class JobRoleDatatable < ApplicationDatatable
  def initialize(params, opts = {})
    @job_roles = opts[:job_roles]
    super
  end

  def view_columns
    @view_columns ||= {
      job_role_id: {source: "JobRole.id", cond: :eq},
      st_code: {source: "JobRole.st_code", cond: :like},
      job_level: {source: "JobRole.job_level", searchable: true, cond: :like},
      job_code: {source: "JobRole.job_code", searchable: true, cond: :like},
      job_family: {source: "JobRole.job_family", searchable: true, cond: :like},
      evaluation_role: {source: nil, searchable: false, orderable: false},
      actions: {source: nil, searchable: false, orderable: false}
    }
  end

  def data
    records.map do |r|
      {
        job_role_id: r.id,
        st_code: r.st_code,
        job_level: r.job_level,
        job_code: r.job_code,
        job_family: r.job_family,
        evaluation_role: render(partial: "datatable/job_role_evaluation_role", locals: {job_role: r}, formats: :html),
        actions: render(partial: "datatable/job_role_action", locals: {job_role: r}, formats: :html),
        DT_RowId: r.id # This will automagically set the id attribute on the corresponding <tr> in the datatable
      }
    end
  end

  def get_raw_records
    @job_roles
  end
end
