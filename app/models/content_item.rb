# IDEA: Perhaps all of this stuff should be in a content module to keep it seperate
# from the rest of the app?

class ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  TYPE_COLLECTION = content_item_types = [
    ["Headline", "HeadlineContentItem"],
    ["Story", "StoryTextContentItem"],
    ["Photo", "PhotoContentItem"],
    ["Video", "VideoContentItem"],
    ["Horizontal Rule", "HorizontalRuleContentItem"]
  ]

  field    :_type,          type: String
  field    :sequence,       type: Integer
  field    :height,         type: Integer

  belongs_to :organization
  belongs_to :content_region

  def page
    @page ||= content_region.page
  end

  def section
    @section ||= page.section
  end

  def edition
    @edition ||= section.edition
  end

  # Returns the computed with of the content region
  def width
    content_region.width
  end

end
