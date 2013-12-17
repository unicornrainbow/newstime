Press::Application.routes.draw do

  root to: 'entries#index', as: :entries

  get '/new' => 'entries#new'

  # Entries
  scope '/entries/', controller: 'entries' do
    get  '/search' => :search
    get  '*path/edit' => :edit
    get  '*path/log' => :log

    get  '*path' => 'entries#show'
    post '*path' => 'entries#update'
  end

  # Images
  scope '/images', controller: 'images' do
    get '/' => :index
    get '*path.png' => :png
    get '*path/edit' => :edit
    get '*path' => :index
  end

  match "*a", :to => "application#routing_error", via: [:get, :post]

end
