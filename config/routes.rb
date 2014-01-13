Press::Application.routes.draw do

  root to: 'editions#index'

  devise_for :users

  resources :editions do
    resource :masthead
    member do
      get :preview
    end
  end

  resources :mastheads
  resources :stories
  resources :photos

  # Active 404
  match "*a", :to => "application#routing_error", via: [:get, :post]

end
