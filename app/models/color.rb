class Color
  include Mongoid::Document

  embedded_in :edition

  field :name,   type: String
  field :value,  type: String

end
