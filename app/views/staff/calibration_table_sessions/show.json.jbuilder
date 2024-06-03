json.company_evaluation_templates do
  @company_evaluation_templates.each do |cet|
    json.set! cet.id do
      json.set! :work_quality_metric do
        json.array! public_send(cet.work_quality_metric) do |k|
          json.label k.first
          json.value k.second
        end
      end
      json.set! :work_load_metric do
        json.array! public_send(cet.work_load_metric) do |k|
          json.label k.first
          json.value k.second
        end
      end
      json.set! :work_attitude_metric do
        json.array! public_send(cet.work_attitude_metric) do |k|
          json.label k.first
          json.value k.second
        end
      end
      json.set! :professional_management_metric do
        json.array! public_send(cet.professional_management_metric) do |k|
          json.label k.first
          json.value k.second
        end
      end
      json.set! :performance_metric do
        json.array! public_send(cet.performance_metric) do |k|
          json.label k.first
          json.value k.second
        end
      end
      json.set! :total_reverse_metric, cet.total_reverse_metric
    end
  end
end
json.need_calibration_eucs do
  json.partial! "need_calibration_eucs", locals: {need_calibration_eucs: @need_calibration_eucs, table_headers_of_performance: @table_headers_of_performance, job_role_evaluation_performances: @job_role_evaluation_performances}
end
