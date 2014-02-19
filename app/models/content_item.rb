class ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field    :type,          type: String
  field    :sequence,      type: Integer

  belongs_to :organization
  belongs_to :content_region
end
