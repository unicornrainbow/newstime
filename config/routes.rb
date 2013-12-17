Press::Application.routes.draw do

  root to: redirect('/editions')

  scope '/editions', controller: 'editions' do
    get '/' => :index, as: :editions
  end

  scope '/stories', controller: 'stories' do
    get '/' => :index, as: :stories
  end

  scope '/photos', controller: 'photos' do
    get '/' => :index, as: :photos
  end

  match "*a", :to => "application#routing_error", via: [:get, :post]

end
