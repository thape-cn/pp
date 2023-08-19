class CapabilityDatatable < ApplicationDatatable
  def initialize(params, opts = {})
    @capabilities = opts[:capabilities]
    super
  end

  def view_columns
    @view_columns ||= {
      en_name: {source: "Capability.en_name", cond: :eq},
      name: {source: "Capability.name", searchable: true, cond: :like},
      category_name: {source: "Capability.category_name", searchable: true, cond: :eq},
      evaluation_roles: {source: nil, searchable: false, orderable: false},
      actions: {source: nil, searchable: false, orderable: false}
    }
  end

  def data
    records.map do |r|
      {
        en_name: r.en_name,
        name: r.name,
        category_name: r.category_name,
        evaluation_roles: render(partial: "datatable/capability_evaluation_roles", locals: {capability: r}, formats: :html),
        actions: render(partial: "datatable/capability_action", locals: {capability: r}, formats: :html),
        DT_RowId: r.id # This will automagically set the id attribute on the corresponding <tr> in the datatable
      }
    end
  end

  def get_raw_records
    @capabilities
  end
end
