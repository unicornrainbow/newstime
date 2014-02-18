class Page
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :section
  belongs_to :organization
  belongs_to :layout

  field      :name,    type: String
  field      :source,  type: String
  field      :number, type: Integer
end
