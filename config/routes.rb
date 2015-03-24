Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :controllers => { :registrations => "registrations" }

  devise_scope :user do
    get :sign_in, to: 'devise/sessions#new', as: :sign_in
    get :sign_up, to: 'devise/registrations#new', as: :sign_up
    delete :sign_out, to: 'devise/sessions#destroy', as: :sign_out
  end

  match '/auth/:provider/callback', to: 'omniauth_callbacks#create', via: [:get, :post], as: :login
  match '/auth/failure', to: 'omniauth_callbacks#failure', via: :get
  get '/users/:id/add_email', to: 'users#add_email', as: :add_email
  patch '/users/:id/finish_signup', to: 'users#finish_signup', as: :finish_signup

  require 'admin_constraint'
  require 'resque/server'
  mount Resque::Server => "/resque", constraints: AdminConstraint.new

  resources :projects do
    collection do
      get :setup_scm
    end
    member do
      get :status
    end

    resources :builds, except: %i(index) do
      member do
        put :rebuild
        put :stop
      end
    end
    resource :hipchat_config
    resource :slack_config

    collection do
      post :github_sync
      post :bitbucket_sync
    end

    member do
      put :activate
      put :deactivate
    end

    resources :memberships, only: %i(destroy)
    resources :invitations, only: %i(create)
  end
  resources :github_projects do
    collection do
      get :setup_scm
      get :import
    end
  end
  resources :bitbucket_projects do
    collection do
      get :setup_scm
      get :import
    end
  end

  resources :users

  resources :projects_analysis_configs do
    member do
      put :toggle
    end
  end

  resources :build_items do
    resources :pull_requests
  end

  resources :omniauth_callbacks, only: %i(create destroy failure)
  resources :jobs, only: %i(show)

  resources :pusher do
    collection do
      post :auth
    end
  end

  authenticated :user do
    root 'projects#index', as: :root
  end

  unauthenticated :user do
    root 'welcome#index', as: :unauthenticated_root
  end
end
