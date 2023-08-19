json.calibration_table_sessions_path staff_calibration_table_session_path(id: @calibration_session.id)
json.accepted @enforce_distribute_reject_message.nil?
json.message @enforce_distribute_reject_message.nil? ? @accept_finalize_confirm_message : @enforce_distribute_reject_message
json.to_calibration_euc do
  json.partial! "to_calibration_euc",
    locals: {need_calibration_evaluation_user_capabilities: @need_calibration_evaluation_user_capabilities,
             blank_data_keys: @blank_data_keys, group_level: @group_level}
end
