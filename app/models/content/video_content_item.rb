module Content
  class VideoContentItem < ContentItem
    field :caption, type: String
    belongs_to :video
  end
end
