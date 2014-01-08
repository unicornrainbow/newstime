Press::Application.routes.draw do

  root to: 'editions#index'

  devise_for :users

  scope '/editions', controller: 'editions' do
    get '/' => :index, as: :editions
    get '/new' => :new, as: :new_edition

    get '/:id' => :show, as: :edition
    delete '/:id' => :delete

    post '/' => :create
  end

  scope '/stories', controller: 'stories' do
    get '/' => :index, as: :stories
    get '/new' => :new, as: :new_story

    get '/:id' => :show, as: :story
    delete '/:id' => :delete

    post '/' => :create
  end

  scope '/photos', controller: 'photos' do
    get '/' => :index, as: :photos
    get '/new' => :new, as: :new_photo

    get '/:id' => :show, as: :photo
    delete '/:id' => :delete

    post '/' => :create
  end

  match "*a", :to => "application#routing_error", via: [:get, :post]


end
