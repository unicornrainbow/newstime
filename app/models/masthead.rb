# The masthead of an edition
class Masthead
  include Mongoid::Document
  field :name, type: String
  field :source, type: String
  has_many :editions
end
