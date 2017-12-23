Rails.application.routes.draw do

  root "static_pages#home"

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :users, only: [:index] do
        get :get_related_users, on: :collection
      end

      resources :tickets, only: [:index, :create, :update] do
        get :dashboard        , on: :collection
        get :search           , on: :collection
        get :get_single_ticket, on: :collection
      end

      resources :groups, only: [:index, :create, :destroy] do
        get :assigned_user_in_group_preload, on: :collection
      end

      resources :group_users, only: [:create, :destroy] do
        get :get_group_not_joined_users, on: :collection
      end

      resources :notifications, only: [:index, :update]

      resources :comments, only: [:create]

      post "sign_in"              , :to => 'sessions#create'
      post "users/change_password", :to => "users#change_password"
      get  "sample_users"         , :to => "sample_users#index"
    end
  end

  get "*path", :to => "static_pages#home"
end
