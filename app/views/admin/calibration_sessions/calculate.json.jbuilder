json.group_level @group_level
if CompanyEvaluationTemplate.staff_distribution_group_level?(@group_level)
  json.apa_grade_rate @result[:apa_grade_rate]
  json.b_grade_rate @result[:b_grade_rate]
  json.cd_grade_rate @result[:cd_grade_rate]
elsif CompanyEvaluationTemplate.manager_distribution_group_level?(@group_level)
  json.beyond_standard_rate @result[:beyond_standard_rate]
  json.standards_compliant_rate @result[:standards_compliant_rate]
  json.below_standard_rate @result[:below_standard_rate]
end
