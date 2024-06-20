namespace :cp do
  root to: "home#index"
  resources :company_evaluations, only: %i[] do
    resources :user_capabilities, only: %i[index] do
      collection do
        get :excel_report
      end
    end
  end
  resources :evaluation_user_capabilities, only: %i[] do
    collection do
      get :expender
    end
  end
end
