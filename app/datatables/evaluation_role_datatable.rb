class EvaluationRoleDatatable < ApplicationDatatable
  def initialize(params, opts = {})
    @evaluation_roles = opts[:evaluation_roles]
    super
  end

  def view_columns
    @view_columns ||= {
      role_name: {source: "EvaluationRole.role_name", cond: :eq},
      capabilities: {source: nil, searchable: false, orderable: false},
      actions: {source: nil, searchable: false, orderable: false}
    }
  end

  def data
    records.map do |r|
      {
        role_name: r.role_name,
        capabilities: render(partial: "datatable/evaluation_role_capabilities", locals: {evaluation_role: r}, formats: :html),
        actions: render(partial: "datatable/evaluation_role_action", locals: {evaluation_role: r}, formats: :html),
        DT_RowId: r.id # This will automagically set the id attribute on the corresponding <tr> in the datatable
      }
    end
  end

  def get_raw_records
    @evaluation_roles
  end
end
