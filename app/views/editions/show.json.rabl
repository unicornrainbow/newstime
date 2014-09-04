object @edition

attributes :_id, :created_at, :updated_at

node(:content_items_attributes) do |edition|
  edition.content_items
end
