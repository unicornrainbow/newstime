# IDEA: Perhaps all of this stuff should be in a content module to keep it seperate
# from the rest of the app?

class Content::ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field    :type,          type: String
  field    :sequence,      type: Integer

  belongs_to :organization
  belongs_to :content_region
end
