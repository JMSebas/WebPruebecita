Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :events do
      collection do
        get :check_due_events # Asegúrate de que esta línea esté presente
      end
    end
      resources :tasks do
        member do
          put 'start_task'
          put 'finish_task'
        end
      end
      
    end
  end

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
  }

  # get "up" => "rails/health#show", as: :rails_health_check
end
