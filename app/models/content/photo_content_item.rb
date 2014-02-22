module Content
  class PhotoContentItem < ContentItem
    field :caption, type: String
    belongs_to :photo
  end
end
