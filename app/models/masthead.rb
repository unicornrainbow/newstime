# The masthead of an edition
class Masthead
  include Mongoid::Document

  field :name, type: String
  field :source, type: String
  field :html, type: String
  has_many :editions

  # Liquid
  liquid_methods :name

end
