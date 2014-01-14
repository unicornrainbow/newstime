class Page
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :section
  belongs_to :organization

  field      :ordinal, type: Integer
  field      :name,    type: String
  field      :source,  type: String
end
