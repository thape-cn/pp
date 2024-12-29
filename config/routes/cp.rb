namespace :cp do
  root to: "home#index"
  resources :company_evaluations, only: %i[] do
    resources :user_capabilities, only: %i[index] do
      collection do
        get :excel_report
      end
    end
    resources :history_user_capabilities, only: %i[index]
  end
  resources :calibration_sessions, only: %i[index show] do
    collection do
      get :expender
    end
  end
  resources :evaluation_user_capabilities, only: %i[] do
    collection do
      get :expender
      get :history_expender
    end
  end
  resources :staff_performances, only: %i[index show] do
    member do
      get :more_people
    end
  end
  resources :auxiliary_performances, only: %i[index show] do
    member do
      get :more_people
    end
  end
  resources :manager_a_performances, only: %i[index show] do
    member do
      get :more_people
    end
  end
end
