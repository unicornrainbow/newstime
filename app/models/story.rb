class Story
  include Mongoid::Document
  field :name, type: String
  field :body, type: String
end
