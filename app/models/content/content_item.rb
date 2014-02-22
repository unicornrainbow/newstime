# IDEA: Perhaps all of this stuff should be in a content module to keep it seperate
# from the rest of the app?

class Content::ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPE_COLLECTION = content_item_types = [
    ["Headline", "Content::HeadlineContentItem"],
    ["Story Text", "Content::StoryTextContentItem"],
    ["Photo", "Content::PhotoContentItem"],
    ["Video", "Content::VideoContentItem"]
  ]


  field    :_type,          type: String
  field    :sequence,      type: Integer

  belongs_to :organization
  belongs_to :content_region
end
