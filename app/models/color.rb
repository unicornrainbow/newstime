class Color
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :edition


  field :name,   type: String
  field :value,  type: String

end
