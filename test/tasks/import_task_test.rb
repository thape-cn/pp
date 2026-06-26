require "test_helper"
require "rake"

class ImportTaskTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.none? { |task| task.name == "import:job_role" }
    Rake::Task["import:job_role"].reenable
  end

  test "import job role reads excel workbook" do
    existing_job_role = JobRole.create!(st_code: "TEST-ST-001", job_level: 1, job_code: "Old", job_family: "Old Family")
    excel_file = Tempfile.new(["job_roles", ".xlsx"], binmode: true)

    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: "job_roles") do |sheet|
      sheet.add_row ["ID", "ST 代码", "岗位职级", "基准岗", "岗位序列", "创建时间", "更新时间", "考评角色"]
      sheet.add_row [26, "TEST-ST-001", 5, "造价工程师", "子公司概预算", "2023-06-15 08:39", "2023-06-15 08:46", "技术员工"]
      sheet.add_row [47, "TEST-ST-002", 9, "资深给排水工程师", "子公司给排水", "2023-06-15 08:39", "2025-09-27 00:12", "技术员工"]
    end
    package.serialize(excel_file.path)

    Rake::Task["import:job_role"].invoke(excel_file.path)

    existing_job_role.reload
    assert_equal 5, existing_job_role.job_level
    assert_equal "造价工程师", existing_job_role.job_code
    assert_equal "子公司概预算", existing_job_role.job_family

    imported_job_role = JobRole.find_by!(st_code: "TEST-ST-002")
    assert_equal 9, imported_job_role.job_level
    assert_equal "资深给排水工程师", imported_job_role.job_code
    assert_equal "子公司给排水", imported_job_role.job_family
  ensure
    excel_file&.close!
  end

  test "import job role still reads employee csv" do
    existing_job_role = JobRole.create!(st_code: "TEST-CSV-001", job_level: 1, job_code: "Old", job_family: "Old Family")
    csv_file = Tempfile.new(["job_roles", ".csv"])

    CSV.open(csv_file.path, "w", write_headers: true, headers: %w[STCODE JOBLEVEL JOBCODE JOBFAMILY]) do |csv|
      csv << ["TEST-CSV-001", 6, "高级造价工程师", "子公司概预算"]
      csv << ["TEST-CSV-002", 7, "主任建筑师", "子公司方案"]
    end

    Rake::Task["import:job_role"].invoke(csv_file.path)

    existing_job_role.reload
    assert_equal 6, existing_job_role.job_level
    assert_equal "高级造价工程师", existing_job_role.job_code
    assert_equal "子公司概预算", existing_job_role.job_family

    imported_job_role = JobRole.find_by!(st_code: "TEST-CSV-002")
    assert_equal 7, imported_job_role.job_level
    assert_equal "主任建筑师", imported_job_role.job_code
    assert_equal "子公司方案", imported_job_role.job_family
  ensure
    csv_file&.close!
  end
end
