# IDEA: Perhaps all of this stuff should be in a content module to keep it seperate
# from the rest of the app?

class ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  embedded_in :edition

  TYPE_COLLECTION = content_item_types = [
    ["Headline", "HeadlineContentItem"],
    ["Story", "StoryTextContentItem"],
    ["Photo", "PhotoContentItem"],
    ["Video", "VideoContentItem"],
    ["Horizontal Rule", "HorizontalRuleContentItem"]
  ]

  ## Attributes
  field    :_type,          type: String
  field    :sequence,       type: Integer
  field    :height,         type: Integer
  field    :page_id,        type: BSON::ObjectId

  def page
    @page ||= page_id && edition.pages.find(page_id)
  end

  def section
    @section ||= page.section
  end

  # Returns the computed with of the content region
  def width
    content_region.width
  end

end
