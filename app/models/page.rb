class Page
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :section
  belongs_to :organization
  belongs_to :layout

  field      :ordinal, type: Integer
  field      :name,    type: String
  field      :source,  type: String
end
