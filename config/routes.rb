Rails.application.routes.draw do

  root "static_pages#home"

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :users, only: [:index]

      resources :tickets, only: [:index, :show] do
        get :dashboard, on: :collection
        get :search   , on: :collection
      end

      post "sign_in"              , :to => 'sessions#create'
      post "users/change_password", :to => "users#change_password"
      get  "sample_users"         , :to => "sample_users#index"
    end
  end

  get "*path", :to => "static_pages#home"
end
