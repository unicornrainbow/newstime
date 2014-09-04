object @edition

attributes :_id, :created_at, :updated_at

child :sections => :sections_attributes do
  attributes :_id, :created_at, :updated_at
end

child :pages => :pages_attributes do
  attributes :_id, :created_at, :updated_at
end

child :content_items => :content_items_attributes do
  attributes :_id, :created_at, :updated_at, :height, :width, :top, :left
end
