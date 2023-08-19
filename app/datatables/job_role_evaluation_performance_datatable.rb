class JobRoleEvaluationPerformanceDatatable < ApplicationDatatable
  def initialize(params, opts = {})
    @job_role_evaluation_performances = opts[:job_role_evaluation_performances]
    super
  end

  def view_columns
    @view_columns ||= {
      chinese_name: {source: "User.chinese_name", searchable: true, cond: :like},
      st_code: {source: "JobRoleEvaluationPerformance.st_code", searchable: true, orderable: true},
      dept_code: {source: "JobRoleEvaluationPerformance.dept_code", searchable: true, orderable: true},
      obj_name: {source: "JobRoleEvaluationPerformance.obj_name", searchable: true, orderable: true},
      obj_weight_pct: {source: "JobRoleEvaluationPerformance.obj_weight_pct", searchable: true, orderable: true},
      obj_result: {source: "JobRoleEvaluationPerformance.obj_result", searchable: true, orderable: false},
      actions: {source: nil, searchable: false, orderable: false}
    }
  end

  def data
    records.map do |r|
      {
        chinese_name: r.user.chinese_name,
        st_code: r.st_code,
        dept_code: r.dept_code,
        obj_name: r.obj_name,
        obj_weight_pct: r.obj_weight_pct,
        obj_result: render(partial: "datatable/job_role_evaluation_performance_obj_result", locals: {job_role_evaluation_performance: r}, formats: :html),
        actions: render(partial: "datatable/job_role_evaluation_performance_action", locals: {job_role_evaluation_performance: r}, formats: :html),
        DT_RowId: r.id # This will automagically set the id attribute on the corresponding <tr> in the datatable
      }
    end
  end

  def get_raw_records
    @job_role_evaluation_performances.includes(:user)
  end
end
