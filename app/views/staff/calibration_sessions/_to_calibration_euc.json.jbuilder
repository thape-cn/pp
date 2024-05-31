need_calibration_evaluation_user_capabilities.keys.each do |key|
  json.set! key do
    json.array! need_calibration_evaluation_user_capabilities[key] do |euc|
      json.id euc.id
      json.user_id euc.user.id
      json.chinese_name euc.user.chinese_name
      json.raw_total_evaluation_score format("%.1f", euc.raw_total_evaluation_score.round(1))
      if group_level == "staff"
        json.work_attitude euc.work_attitude
      end
    end
  end
  blank_data_keys.each do |blank_key|
    json.set! blank_key, []
  end
end
