Press::Application.routes.draw do

  root to: 'editions#index'

  devise_for :users

  scope '/editions', controller: 'editions' do
    get '/' => :index, as: :editions
    get '/new' => :new, as: :new_edition

    get '/:id' => :show, as: :edition

    post '/' => :create
  end

  scope '/stories', controller: 'stories' do
    get '/' => :index, as: :stories
  end

  scope '/photos', controller: 'photos' do
    get '/' => :index, as: :photos
  end

  match "*a", :to => "application#routing_error", via: [:get, :post]


end
