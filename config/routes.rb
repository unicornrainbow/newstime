NoteboxWeb::Application.routes.draw do

  root to: 'entries#index'

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

  # Wiki
  scope '/wiki', controller: 'wiki' do
    get '/' => :index
    get '*path/edit' => :edit
    get '*path' => :show
  end

  # Attachments
  scope '/attachments', controller: 'attachments' do
    get '/' => :index, as: 'attachments'
    get '*path/edit' => :edit
    get '*path' => :show
  end

  # Bookmarks
  scope '/bookmarks', controller: 'bookmarks' do
    get  '/' => :index, as: 'bookmarks'
    get  '/new' => :new

    post '/' => :create
  end

  # Times
  scope '/timers', controller: 'timers' do
    get '/' => :index, as: 'timers'
  end

  # Email
  get '/email' => 'emails#index'

  match "*a", :to => "application#routing_error", via: [:get, :post]

end
