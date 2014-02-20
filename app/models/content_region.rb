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
  has_many :content_items, class_name: 'Content::ContentItem', :inverse_of => :content_region

  def next_content_item_sequence
    content_items.max(:sequence) || 0 + 1
  end

  def resequence_content_items!
    # NOOP for now...
    #content_items.asc(:sequence).each_with_index do |content_item, i|
      #content_items.update_attribute(:sequence, i+1) if content_item.sequence != i+1
    #end
  end
end
