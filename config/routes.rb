NoteboxWeb::Application.routes.draw do

  root to: 'entries#index'
  scope '/entries/' do
    get  'edit/*path' => 'entries#edit'
    get  '*path' => 'entries#show'
    post '*path' => 'entries#update'
  end

  scope '/images', controller: 'images' do
    get '/' => :index
    get '*path.png' => :png
    get '*path/edit' => :edit
    get '*path' => :index
  end

  scope '/wiki', controller: 'wiki' do
    get '/' => :index
    get '*path/edit' => :edit
    get '*path' => :show
  end

  scope '/attachments', controller: 'attachments' do
    get '/' => :index, as: 'attachments'
    get '*path/edit' => :edit
    get '*path' => :show
  end

  scope '/bookmarks', controller: 'bookmarks' do
    get  '/' => :index, as: 'bookmarks'
    get  '/new' => :new

    post '/' => :create
  end

  get '/email' => 'emails#index'

  match "*a", :to => "application#routing_error", via: [:get, :post]

end
