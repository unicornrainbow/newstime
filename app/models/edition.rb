class Edition
  include Mongoid::Document
  field :path, type: String
  field :created_at, type: Time
end
