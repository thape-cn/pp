json.company_evaluation_templates do
  @company_evaluation_templates.each do |cet|
    json.set! cet.id do
      json.set! :work_quality_matric do
        json.array! public_send(cet.work_quality_matric) do |k|
          json.label k.first
          json.value k.second
        end
      end
      json.set! :work_load_matric do
        json.array! public_send(cet.work_load_matric) do |k|
          json.label k.first
          json.value k.second
        end
      end
      json.set! :work_attitude_matric do
        json.array! public_send(cet.work_attitude_matric) do |k|
          json.label k.first
          json.value k.second
        end
      end
      json.set! :professional_management_matric do
        json.array! public_send(cet.professional_management_matric) do |k|
          json.label k.first
          json.value k.second
        end
      end
      json.set! :performance_matric do
        json.array! public_send(cet.performance_matric) do |k|
          json.label k.first
          json.value k.second
        end
      end
      json.set! :total_reverse_matric, cet.total_reverse_matric
    end
  end
end
json.need_review_evaluations do
  json.partial! "need_review_evaluations", locals: {need_review_evaluations: @need_review_evaluations, table_headers_of_performance: @table_headers_of_performance, job_role_evaluation_performances: @job_role_evaluation_performances}
end
