namespace :hr do
  root to: "home#index"
  resources :company_evaluations, only: %i[] do
    resources :user_capabilities, only: %i[index edit update] do
      collection do
        get :excel_report
        get :excel_detail_report
      end
    end
    resources :history_user_capabilities, only: %i[index]
  end
  resources :calibration_sessions, only: %i[index show new create] do
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
  resources :calibration_session_users, only: %i[index] do
    member do
      get :undo_confirm
      put :undo
    end
  end
  resources :evaluation_user_capabilities, only: %i[] do
    member do
      get :overall_text
    end
    collection do
      get :expender
      get :history_expender
    end
  end
  resources :staff_performances, only: %i[index]
  resources :manager_performances, only: %i[index]
end
