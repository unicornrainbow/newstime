Press::Application.routes.draw do

  root to: 'editions#index'

  devise_for :users
  devise_for :admin_user

  resources :editions do
    resource :section
    resource :masthead
    member do
      get :preview
    end
  end

  resources :mastheads do
    member do
      get :preview
    end
  end

  resources :stories
  resources :photos
  resources :videos
  resources :layouts
  resources :partials
  resources :sections

  namespace :admin do
    resources :users
    resources :organizations
  end

  # Active 404
  match "*a", :to => "application#routing_error", via: [:get, :post]

end
