require 'sidekiq/web'

Press::Application.routes.draw do
  root to: redirect('/editions')

  devise_for :users, controllers: { sessions: "sessions" }

  resources :editions do
    resources :sections
    resources :prints
    member do
      get :compose
      asset_routes = lambda do
        get 'fonts/*path'       => :fonts
        get 'images/*path'      => :images
        get 'javascripts/*path' => :javascripts
        get 'stylesheets/*path' => :stylesheets
      end
      scope 'compose' do
        scope controller: :edition_assets, &asset_routes
        get '*path' => :compose, :defaults => { :format => "html" }
      end
      get :preview
      scope 'preview' do
        scope controller: :edition_assets, &asset_routes
        get '*path' => :preview, :defaults => { :format => "html" }
      end
      get :download

      scope 'compile' do
        scope controller: :edition_assets, &asset_routes
        get '*path' => :compile, :defaults => { :format => "html" }
      end
    end
  end

  resources :prints

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
  resources :content_regions
  resources :publications
  resources :content_items do
    collection do
      get :form
    end
  end
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

  namespace :api do
    resources :story_text_content_items, only: [:create, :update]
  end

  #namespace :admin do
    #resources :users
    #resources :organizations
  #end

  get '/logo' => 'application#logo'

  scope controller: :webpages do
    get :lbs_demo
  end

  mount Sidekiq::Web, at: "/sidekiq"

  # Active 404
  match "*a", :to => "application#routing_error", via: [:get, :post]

end
