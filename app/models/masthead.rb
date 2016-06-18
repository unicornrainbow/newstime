class Masthead
  include Mongoid::Document

  embedded_in :edition

  field :height, type: Integer
  field :lock,   type: Boolean

  field :artwork_height, type: Integer

  has_mongoid_attached_file :artwork

end
