attributes *Edition.attribute_names

child :sections => :sections_attributes do
  attributes *Section.attribute_names
end

child :pages => :pages_attributes do
  attributes *Page.attribute_names
  attributes :page_ref
end

child :content_items => :content_items_attributes do |content_items|
  content_items.map do |content_item|
    attributes *content_item.attribute_names
  end
end
