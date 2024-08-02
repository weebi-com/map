Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount ActionCable.server => '/cable'
  mount MissionControl::Jobs::Engine, at: '/jobs'

  # Defines the root path route ("/")
  root 'map_viewer#index'

  resources :imports, only: [:new, :create] do
    collection do
      post :categories
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  devise_for :users, path: '/', path_names: { sign_in: 'login', sign_out: 'logout' }, only: [:sessions]

  resources :imports, only: %i[new categories create]

  namespace :api do
    namespace :v1 do
      resources :entreprises, only: [:index]
    end
  end
end
