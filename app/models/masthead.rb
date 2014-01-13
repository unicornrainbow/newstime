# The masthead of an edition
class Masthead
  include Mongoid::Document
  field :name, type: String
  belongs_to :edition
end
