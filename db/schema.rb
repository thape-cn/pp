# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_07_15_000000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "archived_evaluation_user_capabilities", force: :cascade do |t|
    t.decimal "annual_output", precision: 5, scale: 2
    t.decimal "architectural_representation_presentation", precision: 5, scale: 2
    t.decimal "best_plan", precision: 5, scale: 2
    t.decimal "build_team", precision: 5, scale: 2
    t.integer "calibration_management_profession_score"
    t.integer "calibration_management_score"
    t.integer "calibration_performance_score"
    t.integer "calibration_profession_score"
    t.integer "calibration_work_attitude"
    t.integer "calibration_work_load"
    t.integer "calibration_work_quality"
    t.boolean "capability_columns_all_null", default: false, null: false
    t.decimal "coaching", precision: 5, scale: 2
    t.decimal "collaboration", precision: 5, scale: 2
    t.string "company", null: false
    t.bigint "company_evaluation_template_id", null: false
    t.decimal "concept", precision: 5, scale: 2
    t.decimal "cooperation", precision: 5, scale: 2
    t.decimal "craftsmanship", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.decimal "customer_insight", precision: 5, scale: 2
    t.decimal "customer_needs", precision: 5, scale: 2
    t.decimal "customer_needs_non", precision: 5, scale: 2
    t.string "deleted_reason"
    t.datetime "deleted_time", null: false
    t.integer "deleted_user_id", null: false
    t.string "department", null: false
    t.string "dept_code", null: false
    t.float "final_total_evaluation_score"
    t.string "form_status", default: "initial"
    t.decimal "goal_achieved", precision: 5, scale: 2
    t.decimal "graphic_interior", precision: 5, scale: 2
    t.decimal "graphic_interior_aico", precision: 5, scale: 2
    t.decimal "graphic_landscape", precision: 5, scale: 2
    t.decimal "graphic_planning", precision: 5, scale: 2
    t.decimal "graphic_quality", precision: 5, scale: 2
    t.decimal "graphic_quality_landscape", precision: 5, scale: 2
    t.decimal "high_efficiency", precision: 5, scale: 2
    t.decimal "high_quality", precision: 5, scale: 2
    t.decimal "identify_business_pain", precision: 5, scale: 2
    t.decimal "implementation", precision: 5, scale: 2
    t.decimal "implementation_interior_aico", precision: 5, scale: 2
    t.decimal "implementation_landscape", precision: 5, scale: 2
    t.decimal "innovation", precision: 5, scale: 2
    t.bigint "job_role_id", null: false
    t.decimal "learning", precision: 5, scale: 2
    t.decimal "logic", precision: 5, scale: 2
    t.decimal "logic_landscape", precision: 5, scale: 2
    t.text "manager_overall_improvement"
    t.text "manager_overall_output"
    t.text "manager_overall_plan"
    t.float "manager_scored_total_evaluation_score"
    t.bigint "manager_user_id"
    t.decimal "mission_consensus", precision: 5, scale: 2
    t.decimal "norms", precision: 5, scale: 2
    t.decimal "norms_landscape", precision: 5, scale: 2
    t.decimal "onsite", precision: 5, scale: 2
    t.decimal "onsite_landscape", precision: 5, scale: 2
    t.decimal "organizational_capabilities", precision: 5, scale: 2
    t.decimal "planning", precision: 5, scale: 2
    t.decimal "planning_interior", precision: 5, scale: 2
    t.decimal "planning_landscape", precision: 5, scale: 2
    t.decimal "presentation", precision: 5, scale: 2
    t.decimal "presentation_arch", precision: 5, scale: 2
    t.decimal "presentation_interior_aico", precision: 5, scale: 2
    t.decimal "presentation_landscape", precision: 5, scale: 2
    t.decimal "presentation_planning", precision: 5, scale: 2
    t.decimal "product_design_landscape", precision: 5, scale: 2
    t.decimal "professional_level", precision: 5, scale: 2
    t.decimal "realization", precision: 5, scale: 2
    t.decimal "realization_landscape", precision: 5, scale: 2
    t.decimal "results", precision: 5, scale: 2
    t.text "self_overall_improvement"
    t.text "self_overall_output"
    t.text "self_overall_plan"
    t.decimal "set_vision_goals", precision: 5, scale: 2
    t.decimal "shape", precision: 5, scale: 2
    t.decimal "shape_interior", precision: 5, scale: 2
    t.date "sign_date"
    t.decimal "space_creativity", precision: 5, scale: 2
    t.decimal "team_atmosphere", precision: 5, scale: 2
    t.decimal "technical", precision: 5, scale: 2
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "work_attitude", precision: 5, scale: 2
    t.decimal "work_load", precision: 5, scale: 2
    t.decimal "work_quality", precision: 5, scale: 2
    t.index ["deleted_user_id"], name: "index_archived_evaluation_user_capabilities_on_deleted_user_id"
  end

  create_table "calibration_session_judges", force: :cascade do |t|
    t.integer "calibration_session_id", null: false
    t.datetime "created_at", null: false
    t.integer "judge_id", null: false
    t.datetime "updated_at", null: false
    t.index ["calibration_session_id"], name: "index_calibration_session_judges_on_calibration_session_id"
    t.index ["judge_id"], name: "index_calibration_session_judges_on_judge_id"
  end

  create_table "calibration_session_save_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "calibration_session_id", null: false
    t.datetime "created_at", null: false
    t.string "group_level", null: false
    t.datetime "saved_at", null: false
    t.bigint "saved_by_id", null: false
    t.json "scores_snapshot", null: false
    t.string "source", null: false
    t.datetime "updated_at", null: false
    t.index ["calibration_session_id"], name: "index_calibration_session_save_logs_on_calibration_session_id"
    t.index ["saved_at"], name: "index_calibration_session_save_logs_on_saved_at"
    t.index ["saved_by_id"], name: "index_calibration_session_save_logs_on_saved_by_id"
  end

  create_table "calibration_session_users", force: :cascade do |t|
    t.integer "calibration_session_id", null: false
    t.datetime "created_at", null: false
    t.integer "evaluation_user_capability_id", null: false
    t.integer "new_calibration_session_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["calibration_session_id"], name: "index_calibration_session_users_on_calibration_session_id"
    t.index ["evaluation_user_capability_id"], name: "idx_on_evaluation_user_capability_id_08738755c2"
    t.index ["new_calibration_session_id"], name: "index_calibration_session_users_on_new_calibration_session_id"
    t.index ["user_id"], name: "index_calibration_session_users_on_user_id"
  end

  create_table "calibration_sessions", force: :cascade do |t|
    t.integer "calibration_template_id", null: false
    t.datetime "created_at", null: false
    t.integer "hr_reviewer_id"
    t.integer "owner_id", null: false
    t.string "session_name"
    t.string "session_status", default: "waiting_manager_score", null: false
    t.datetime "updated_at", null: false
    t.index ["calibration_template_id"], name: "index_calibration_sessions_on_calibration_template_id"
    t.index ["hr_reviewer_id"], name: "index_calibration_sessions_on_hr_reviewer_id"
    t.index ["owner_id"], name: "index_calibration_sessions_on_owner_id"
  end

  create_table "calibration_templates", force: :cascade do |t|
    t.integer "apa_grade_rate", default: 30, null: false
    t.integer "b_grade_rate", default: 40, null: false
    t.integer "below_standard_rate", default: 30, null: false
    t.integer "beyond_standard_rate", default: 30, null: false
    t.integer "cd_grade_rate", default: 30, null: false
    t.integer "company_evaluation_template_id", null: false
    t.datetime "created_at", null: false
    t.boolean "enforce_distribute", default: false, null: false
    t.boolean "enforce_highest_only", default: false, null: false
    t.integer "standards_compliant_rate", default: 40, null: false
    t.string "template_name"
    t.datetime "updated_at", null: false
    t.index ["company_evaluation_template_id"], name: "index_calibration_templates_on_company_evaluation_template_id"
  end

  create_table "capabilities", force: :cascade do |t|
    t.string "category_name"
    t.datetime "created_at", null: false
    t.string "description"
    t.string "en_name"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "company_evaluation_templates", force: :cascade do |t|
    t.text "brief"
    t.integer "company_evaluation_id", null: false
    t.datetime "created_at", null: false
    t.string "group_level", default: "staff"
    t.integer "management_subtotal_rate", default: 15, null: false
    t.string "manager_overall_improvement_hint"
    t.string "manager_overall_output_hint"
    t.string "manager_overall_plan_hint"
    t.integer "pct_proportion", default: 100
    t.string "performance_metric", default: "grading_5_metric"
    t.integer "performance_subtotal_rate", default: 50, null: false
    t.integer "profession_subtotal_rate", default: 35, null: false
    t.string "professional_management_metric", default: "grading_5_metric"
    t.integer "rate_proportion", default: 0
    t.string "self_overall_improvement_hint"
    t.string "self_overall_output_hint"
    t.string "self_overall_plan_hint"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "work_attitude_metric", default: "grading_5_metric"
    t.integer "work_attitude_pct", default: 15, null: false
    t.string "work_load_metric", default: "grading_5_metric"
    t.integer "work_load_pct", default: 50, null: false
    t.string "work_quality_metric", default: "grading_5_metric"
    t.integer "work_quality_pct", default: 35, null: false
    t.index ["company_evaluation_id"], name: "index_company_evaluation_templates_on_company_evaluation_id"
  end

  create_table "company_evaluations", force: :cascade do |t|
    t.string "bonus_period"
    t.datetime "created_at", null: false
    t.date "end_date"
    t.boolean "evaluation_ended", default: false
    t.date "start_date"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "corp_president_managed_companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "managed_company"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_corp_president_managed_companies_on_user_id"
  end

  create_table "ended_company_evaluation_role_capabilities", force: :cascade do |t|
    t.integer "capability_id", null: false
    t.string "cerc_description", null: false
    t.integer "company_evaluation_id", null: false
    t.datetime "created_at", null: false
    t.integer "evaluation_role_id", null: false
    t.datetime "updated_at", null: false
    t.index ["capability_id"], name: "idx_on_capability_id_d6bf371b11"
    t.index ["company_evaluation_id"], name: "idx_on_company_evaluation_id_2f24666afc"
    t.index ["evaluation_role_id"], name: "idx_on_evaluation_role_id_68bb1a78bc"
  end

  create_table "euc_form_status_histories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "evaluation_user_capability_id", null: false
    t.string "form_status"
    t.string "previous_form_status"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["evaluation_user_capability_id"], name: "idx_on_evaluation_user_capability_id_a9dc1f363d"
    t.index ["user_id"], name: "index_euc_form_status_histories_on_user_id"
  end

  create_table "evaluation_role_capabilities", force: :cascade do |t|
    t.integer "capability_id", null: false
    t.datetime "created_at", null: false
    t.string "erc_description"
    t.integer "evaluation_role_id", null: false
    t.datetime "updated_at", null: false
    t.index ["capability_id"], name: "index_evaluation_role_capabilities_on_capability_id"
    t.index ["evaluation_role_id"], name: "index_evaluation_role_capabilities_on_evaluation_role_id"
  end

  create_table "evaluation_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "role_name"
    t.datetime "updated_at", null: false
  end

  create_table "evaluation_user_capabilities", force: :cascade do |t|
    t.decimal "annual_output", precision: 5, scale: 2
    t.decimal "architectural_representation_presentation", precision: 5, scale: 2
    t.decimal "best_plan", precision: 5, scale: 2
    t.decimal "build_team", precision: 5, scale: 2
    t.integer "calibration_management_profession_score"
    t.integer "calibration_management_score"
    t.integer "calibration_performance_score"
    t.integer "calibration_profession_score"
    t.integer "calibration_work_attitude"
    t.integer "calibration_work_load"
    t.integer "calibration_work_quality"
    t.boolean "capability_columns_all_null", default: false, null: false
    t.decimal "coaching", precision: 5, scale: 2
    t.decimal "collaboration", precision: 5, scale: 2
    t.string "company", null: false
    t.integer "company_evaluation_template_id", null: false
    t.decimal "concept", precision: 5, scale: 2
    t.decimal "cooperation", precision: 5, scale: 2
    t.decimal "craftsmanship", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.decimal "customer_insight", precision: 5, scale: 2
    t.decimal "customer_needs", precision: 5, scale: 2
    t.decimal "customer_needs_non", precision: 5, scale: 2
    t.string "department", null: false
    t.string "dept_code", null: false
    t.string "edoc_file_id"
    t.string "edoc_guid"
    t.string "final_total_evaluation_grade"
    t.float "final_total_evaluation_score"
    t.string "form_status", default: "initial"
    t.decimal "goal_achieved", precision: 5, scale: 2
    t.decimal "graphic_interior", precision: 5, scale: 2
    t.decimal "graphic_interior_aico", precision: 5, scale: 2
    t.decimal "graphic_landscape", precision: 5, scale: 2
    t.decimal "graphic_planning", precision: 5, scale: 2
    t.decimal "graphic_quality", precision: 5, scale: 2
    t.decimal "graphic_quality_landscape", precision: 5, scale: 2
    t.decimal "high_efficiency", precision: 5, scale: 2
    t.decimal "high_quality", precision: 5, scale: 2
    t.decimal "identify_business_pain", precision: 5, scale: 2
    t.decimal "implementation", precision: 5, scale: 2
    t.decimal "implementation_interior_aico", precision: 5, scale: 2
    t.decimal "implementation_landscape", precision: 5, scale: 2
    t.decimal "innovation", precision: 5, scale: 2
    t.integer "job_role_id", null: false
    t.decimal "learning", precision: 5, scale: 2
    t.decimal "logic", precision: 5, scale: 2
    t.decimal "logic_landscape", precision: 5, scale: 2
    t.text "manager_overall_improvement"
    t.text "manager_overall_output"
    t.text "manager_overall_plan"
    t.float "manager_scored_total_evaluation_score"
    t.integer "manager_user_id"
    t.decimal "mission_consensus", precision: 5, scale: 2
    t.decimal "norms", precision: 5, scale: 2
    t.decimal "norms_landscape", precision: 5, scale: 2
    t.decimal "onsite", precision: 5, scale: 2
    t.decimal "onsite_landscape", precision: 5, scale: 2
    t.decimal "organizational_capabilities", precision: 5, scale: 2
    t.decimal "planning", precision: 5, scale: 2
    t.decimal "planning_interior", precision: 5, scale: 2
    t.decimal "planning_landscape", precision: 5, scale: 2
    t.decimal "presentation", precision: 5, scale: 2
    t.decimal "presentation_arch", precision: 5, scale: 2
    t.decimal "presentation_interior_aico", precision: 5, scale: 2
    t.decimal "presentation_landscape", precision: 5, scale: 2
    t.decimal "presentation_planning", precision: 5, scale: 2
    t.decimal "product_design_landscape", precision: 5, scale: 2
    t.decimal "professional_level", precision: 5, scale: 2
    t.decimal "realization", precision: 5, scale: 2
    t.decimal "realization_landscape", precision: 5, scale: 2
    t.decimal "results", precision: 5, scale: 2
    t.text "self_overall_improvement"
    t.text "self_overall_output"
    t.text "self_overall_plan"
    t.decimal "set_vision_goals", precision: 5, scale: 2
    t.decimal "shape", precision: 5, scale: 2
    t.decimal "shape_interior", precision: 5, scale: 2
    t.date "sign_date"
    t.decimal "space_creativity", precision: 5, scale: 2
    t.decimal "team_atmosphere", precision: 5, scale: 2
    t.decimal "technical", precision: 5, scale: 2
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.decimal "work_attitude", precision: 5, scale: 2
    t.decimal "work_load", precision: 5, scale: 2
    t.decimal "work_quality", precision: 5, scale: 2
    t.index ["job_role_id"], name: "index_evaluation_user_capabilities_on_job_role_id"
    t.index ["manager_user_id"], name: "index_evaluation_user_capabilities_on_manager_user_id"
    t.index ["user_id"], name: "index_evaluation_user_capabilities_on_user_id"
  end

  create_table "evaluation_user_capability_descriptions", force: :cascade do |t|
    t.integer "capability_id", null: false
    t.integer "company_evaluation_template_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["capability_id"], name: "index_evaluation_user_capability_descriptions_on_capability_id"
    t.index ["company_evaluation_template_id"], name: "idx_on_company_evaluation_template_id_22b2013026"
    t.index ["user_id"], name: "index_evaluation_user_capability_descriptions_on_user_id"
  end

  create_table "hr_user_managed_companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "managed_company"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_hr_user_managed_companies_on_user_id"
  end

  create_table "hrbp_user_managed_departments", force: :cascade do |t|
    t.boolean "auto_managed", default: false, null: false
    t.datetime "created_at", null: false
    t.string "managed_dept_code"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_hrbp_user_managed_departments_on_user_id"
  end

  create_table "import_excel_file_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "import_excel_file_id", null: false
    t.string "message"
    t.integer "row_number"
    t.datetime "updated_at", null: false
    t.index ["import_excel_file_id"], name: "index_import_excel_file_messages_on_import_excel_file_id"
  end

  create_table "import_excel_files", force: :cascade do |t|
    t.integer "company_evaluation_id", null: false
    t.datetime "created_at", null: false
    t.string "file_status", default: "do_validating", null: false
    t.string "import_type", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["company_evaluation_id"], name: "index_import_excel_files_on_company_evaluation_id"
    t.index ["user_id"], name: "index_import_excel_files_on_user_id"
  end

  create_table "job_role_evaluation_performances", force: :cascade do |t|
    t.integer "company_evaluation_id", null: false
    t.datetime "created_at", null: false
    t.string "dept_code", null: false
    t.string "en_name"
    t.integer "evaluation_user_capability_id"
    t.string "import_guid", null: false
    t.text "obj_metric"
    t.string "obj_name", null: false
    t.integer "obj_result"
    t.boolean "obj_result_fixed", default: true
    t.integer "obj_weight_pct", default: 0, null: false
    t.string "st_code", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["company_evaluation_id"], name: "idx_on_company_evaluation_id_0c1a9c1fa4"
    t.index ["evaluation_user_capability_id"], name: "idx_on_evaluation_user_capability_id_e9250cbc67"
    t.index ["user_id"], name: "index_job_role_evaluation_performances_on_user_id"
  end

  create_table "job_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "evaluation_role_id"
    t.string "job_code"
    t.string "job_family"
    t.integer "job_level"
    t.string "st_code"
    t.datetime "updated_at", null: false
    t.index ["evaluation_role_id"], name: "index_job_roles_on_evaluation_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "role_name"
    t.datetime "updated_at", null: false
  end

  create_table "secretary_managed_departments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "managed_dept_code"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_secretary_managed_departments_on_user_id"
  end

  create_table "user_job_roles", force: :cascade do |t|
    t.string "company"
    t.datetime "created_at", null: false
    t.string "department"
    t.string "dept_code"
    t.boolean "is_active", default: false, null: false
    t.integer "job_role_id", null: false
    t.string "job_user_id"
    t.integer "manager_user_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["job_role_id"], name: "index_user_job_roles_on_job_role_id"
    t.index ["manager_user_id"], name: "index_user_job_roles_on_manager_user_id"
    t.index ["user_id"], name: "index_user_job_roles_on_user_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "role_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "chinese_name", null: false
    t.string "clerk_code", null: false
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.date "hire_date", null: false
    t.boolean "is_active", default: false, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "preferred_language"
    t.integer "preferred_page_length", default: 10, null: false
    t.boolean "read_manager_instruction", default: false, null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.boolean "sidebar_narrow", default: false, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "wecom_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "calibration_session_judges", "calibration_sessions"
  add_foreign_key "calibration_session_save_logs", "calibration_sessions"
  add_foreign_key "calibration_session_save_logs", "users", column: "saved_by_id"
  add_foreign_key "calibration_session_users", "calibration_sessions"
  add_foreign_key "calibration_session_users", "users"
  add_foreign_key "calibration_sessions", "calibration_templates"
  add_foreign_key "calibration_templates", "company_evaluation_templates"
  add_foreign_key "company_evaluation_templates", "company_evaluations"
  add_foreign_key "euc_form_status_histories", "evaluation_user_capabilities"
  add_foreign_key "evaluation_role_capabilities", "capabilities"
  add_foreign_key "evaluation_role_capabilities", "evaluation_roles"
  add_foreign_key "evaluation_user_capabilities", "job_roles"
  add_foreign_key "evaluation_user_capabilities", "users"
  add_foreign_key "import_excel_file_messages", "import_excel_files"
  add_foreign_key "job_role_evaluation_performances", "company_evaluations"
  add_foreign_key "job_role_evaluation_performances", "evaluation_user_capabilities"
  add_foreign_key "job_role_evaluation_performances", "users"
  add_foreign_key "job_roles", "evaluation_roles"
  add_foreign_key "user_job_roles", "job_roles"
  add_foreign_key "user_job_roles", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
