require "sidekiq/web"

namespace :admin do
  root to: "home#index"
  resource :hr_home, only: %i[show]

  resources :company_evaluations, only: %i[index new create edit update] do
    resources :templates, controller: "evaluation_templates", only: %i[index new create edit update] do
      resources :calibration_templates, only: %i[new create edit update destroy] do
        member do
          get :confirm_destroy
        end
      end
    end
    resources :user_capabilities, except: %i[destroy] do
      member do
        get :custom_description_dialog
        post :custom_description
      end
      collection do
        get :excel_report
        get :excel_detail_report
        get :sent_hr_review_completed_confirm
        post :sent_hr_review_completed_remind
        get :sent_self_assessment_confirm
        post :sent_self_assessment_remind
      end
    end
    resources :user_descriptions, only: %i[index]
    resources :history_user_capabilities, only: %i[index]
    resources :archived_user_capabilities, only: %i[index] do
      member do
        get :confirm_restore
        put :restore
      end
      collection do
        get :excel_report
      end
    end
    resources :user_calibrations, only: %i[index] do
      collection do
        get :excel_report
      end
    end
    resources :performances, controller: "user_job_role_performances", only: %i[index edit update new create] do
      collection do
        get :excel_report
      end
    end
    resources :import_excel_files, only: %i[index show destroy] do
      member do
        get :destroy_confirm
        get :do_import_confirm
        put :do_import
      end
    end
    member do
      get :confirm_remove_leaving_employee_eucs
      put :remove_leaving_employee_eucs
      get :confirm_to_end_evaluation
      put :to_end_evaluation
      get :confirm_filling_final_total_evaluation_grade
      put :filling_final_total_evaluation_grade
    end
  end # of company_evaluations

  resources :company_evaluation_templates, only: %i[] do
    collection do
      get :all
      get :expender
    end
  end
  resources :user_job_role_performances, only: %i[] do
    collection do
      get :expender
    end
  end
  resources :evaluation_user_capabilities, only: %i[create destroy] do
    member do
      get :overall_text
      get :confirm_destroy
    end
    collection do
      get :expender
      get :history_expender
    end
  end
  resources :calibration_session_users, only: %i[destroy] do
    member do
      get :undo_confirm
      put :undo
      get :confirm_destroy
    end
    collection do
      get :expender
    end
  end
  resources :calibration_sessions do
    member do
      get :approve_confirm
      put :approve
      get :undo_confirm
      put :undo
      get :destroy_confirm
    end
    collection do
      get :expender
      get :calculate
      post :reconcile_session_status
    end
  end
  resources :import_excel_files, only: %i[] do
    collection do
      get :expender
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
  resources :manager_performances, only: %i[index show] do
    member do
      get :more_people
    end
  end
  resources :users, only: %i[index edit update new create] do
    member do
      get :impersonation
      patch :sign_in_as
      get :new_evaluation
    end
    collection do
      get :excel_report
      get :change_manager_confirm
      put :change_manager
    end
  end
  resources :duplicate_users, only: %i[index edit update]
  resources :hrbp_managed_departments, only: %i[index]
  resources :secretary_managed_departments, only: %i[index]
  resources :job_roles, only: %i[index edit update] do
    collection do
      get :excel_report
    end
  end
  resources :roles, only: %i[index new create edit update] do
    resources :role_users, only: %i[index]
    collection do
      get :expender
    end
  end
  resources :evaluation_roles, only: %i[index edit update]
  resources :capabilities, only: %i[index edit update] do
    resources :evaluation_role_capabilities, only: %i[update]
  end
  resource :background_jobs, only: %i[show]
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end
end
