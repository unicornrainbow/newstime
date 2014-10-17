object @edition

attributes *Edition.attribute_names

child :sections => :sections_attributes do
  attributes *Section.attribute_names
end

child :pages => :pages_attributes do
  attributes *Page.attribute_names
end

child :content_items => :content_items_attributes do
  #attributes :_id, :created_at, :updated_at, :height, :width, :top, :left
  attributes *ContentItem.attribute_names + [:text]
end
