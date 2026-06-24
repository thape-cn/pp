if @need_review_evaluations.none?
  json.go_path staff_root_path
else
  json.go_path staff_mark_score_path(id: current_user.id, company_evaluation_ids: @company_evaluation_ids)
end
