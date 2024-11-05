Rails.application.routes.draw do
  
  namespace :api do
    namespace :v1 do
      resources :projects do
        resources :tasks
      end
    end
  end
  

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
  }

  # get "up" => "rails/health#show", as: :rails_health_check
end
