class Edition
  include Mongoid::Document
  field :name, type: String
  field :path, type: String
  field :source, type: String
  field :created_at, type: Time
  field :html, type: String
end
