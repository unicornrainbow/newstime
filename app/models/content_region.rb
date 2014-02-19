class ContentRegion
  include Mongoid::Document
  include Mongoid::Timestamps

  field      :column_width,  type: Integer
  field      :pixel_height,  type: Integer

  belongs_to :organization
  belongs_to :page
end
