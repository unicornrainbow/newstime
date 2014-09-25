require 'sidekiq/web'

Press::Application.routes.draw do
  root to: redirect('/editions')

  devise_for :users, controllers: { sessions: "sessions" }

  resources :editions do
    resources :sections
    resources :content_items
    resources :pages
    resources :prints, only: ['index', 'create'] do
      member do
        get '(*path)' => :show, as: 'show'
      end
    end

    member do
      get :compose
      asset_routes = lambda do
        get 'fonts/*path'       => :fonts
        get 'images/*path'      => :images
        get 'videos/*path'      => :videos
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

  resources :prints, except: 'show' do
    member do
      get :download
      put :publish
      get 'view/*path' => :view, :defaults => { :format => "html" }
    end
  end

  resources :mastheads do
    member do
      get :preview
    end
  end

  resources :stories
  resources :photos
  resources :videos do
    member do
      post :set_cover
    end

  end


  resources :layouts
  resources :partials
  resources :inlets
  resources :content_regions do
    member do
      put :move
    end
  end
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
