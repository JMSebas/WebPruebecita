Rails.application.routes.draw do

  namespace :api do 
    namespace :v1 do
      resources :events
      resources :tasks do
        member do
          patch 'start_task'
          patch 'finish_task'
        end
      end
    end 
  end

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  
  # get "up" => "rails/health#show", as: :rails_health_check

  
end
