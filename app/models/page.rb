class Page
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :section
  field      :ordinal, type: Integer
end
