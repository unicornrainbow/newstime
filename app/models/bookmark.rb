class Bookmark
  include Mongoid::Document

  field :title
  field :url
  field :description
  field :created_at, type: DateTime
end
