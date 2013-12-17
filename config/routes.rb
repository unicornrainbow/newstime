Press::Application.routes.draw do

  root to: 'editions#index', as: :entries

  resources :editions

  get '/new' => 'entries#new'

  # Images
  scope '/images', controller: 'images' do
    get '/' => :index
    get '*path.png' => :png
    get '*path/edit' => :edit
    get '*path' => :index
  end

  match "*a", :to => "application#routing_error", via: [:get, :post]

end
