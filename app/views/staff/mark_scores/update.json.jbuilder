json.accepted @mark_score_confirm_reject_message.blank?
json.message @mark_score_confirm_reject_message.blank? ? @accept_mark_score_confirm_message : @mark_score_confirm_reject_message
json.need_review_evaluations do
  json.partial! "need_review_evaluations",
    locals: {need_review_evaluations: @need_review_evaluations,
             table_headers_of_performance: @table_headers_of_performance,
             ercs: @ercs,
             job_role_evaluation_performances: @job_role_evaluation_performances}
end
