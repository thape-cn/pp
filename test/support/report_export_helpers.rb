module ReportExportHelpers
  def create_report_export(report_type: "admin_evaluation_details", user: users(:user_guochunzhong), **attributes)
    ReportExport.create!({user: user, report_type: report_type, locale: "zh-CN",
                          company_evaluation: company_evaluations(:ce_one)}.merge(attributes))
  end

  def with_report_workbook(report_export)
    report_export.file.open do |file|
      yield Roo::Excelx.new(file.path)
    end
  end

  # Minitest 6 no longer bundles minitest/mock.
  def with_replaced_method(object, method, replacement)
    singleton = object.singleton_class
    own_method = singleton.method_defined?(method, false)
    original = object.method(method)
    singleton.define_method(method, replacement)
    yield
  ensure
    if own_method
      singleton.define_method(method, original)
    else
      singleton.remove_method(method)
    end
  end

  def purge_report_files
    ReportExport.find_each { |report_export| report_export.file.purge if report_export.file.attached? }
  end
end
