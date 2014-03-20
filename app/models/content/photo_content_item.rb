module Content
  class PhotoContentItem < ContentItem
    field :caption, type: String
    belongs_to :photo

    def photo_url
      photo.attachment.url
    end
  end
end
