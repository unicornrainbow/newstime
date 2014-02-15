Press::Application.routes.draw do

  root to: 'editions#index'
  #root to: 'webpages#home'

  devise_for :users
  devise_for :admin_user

  resources :editions do
    resources :sections
    member do
      get :compose
      scope 'compose' do
        get 'fonts/*path'       => :fonts
        get 'images/*path'      => :images
        get 'javascripts/*path' => :javascripts
        get 'stylesheets/*path' => :stylesheets
        get '*path' => :compose, :defaults => { :format => "html" }
      end

      get :preview
      scope 'preview' do
        get 'fonts/*path'       => :fonts
        get 'images/*path'      => :images
        get 'javascripts/*path' => :javascripts
        get 'stylesheets/*path' => :stylesheets
        get '*path' => :preview, :defaults => { :format => "html" }
      end

      get :download
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
  resources :inlets
  resources :pages do
    member do
      get :preview
    end
  end


  resources :sections do
    resources :pages
    member do
      get :preview
    end
  end

  namespace :admin do
    resources :users
    resources :organizations
  end

  get '/logo' => 'application#logo'

  # Active 404
  match "*a", :to => "application#routing_error", via: [:get, :post]

end
