class Section
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  belongs_to :edition
  belongs_to :layout
  has_many   :pages
  field      :ordinal, type: Integer
end
