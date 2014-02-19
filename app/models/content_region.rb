class ContentRegion
  include Mongoid::Document
  include Mongoid::Timestamps

  field      :column_width,  type: Integer
  field      :pixel_height,  type: Integer
  # Which row is the contnet region on.
  field      :row_sequence,  type: Integer, default: 1
  field      :sequence,      type: Integer

  belongs_to :organization
  belongs_to :page
end
