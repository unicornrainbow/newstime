class Section
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :path, type: String
  field :sequence, type: Integer

  field :template_name, type: String

  belongs_to :edition
  belongs_to :layout
  belongs_to :organization
  has_many   :pages
  field      :ordinal, type: Integer
end
