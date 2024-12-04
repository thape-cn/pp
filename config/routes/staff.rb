namespace :staff do
  root to: "home#index"
  resources :company_evaluations, only: %i[] do
    resources :user_capabilities, only: %i[index] do
      collection do
        get :excel_report
        get :excel_detail_report
      end
    end
    resources :history_user_capabilities, only: %i[index]
  end
  resource :evaluation_progress, only: %i[show]
  resources :printing, only: %i[show] do     # 员工用于打印的表单
    member do
      get :pdf
    end
  end
  resources :signing, only: %i[show update]  # 员工签名表单
  resources :in_evaluation, only: %i[show]   # 在途评价表单
  resources :evaluations, only: %i[show update] do # 员工自评表单
    collection do
      get :expender
    end
  end
  resource :read_manager_instruction, only: %i[show create]
  resources :mark_scores, only: %i[show update] do
    member do
      put :score_confirm
    end
  end
  resources :calibration_sessions, only: %i[index show update] do
    member do
      put :finalize_calibration
      get :fixed
    end
    collection do
      get :expender
    end
  end
  resources :proofreading_calibration_sessions, only: %i[index show] do
    member do
      get :approve_confirm
      put :approve
      get :undo_confirm
      put :undo
    end
    collection do
      get :expender
    end
  end
  resources :calibration_session_users, only: %i[] do
    member do
      get :undo_confirm
      put :undo
    end
  end
  resources :calibration_table_sessions, only: %i[show update]
  resources :evaluation_user_capabilities, only: %i[show update] do
    member do
      get :overall_text
    end
    collection do
      get :history_expender
    end
  end
  resources :user_job_role_performances, only: %i[show]
end
