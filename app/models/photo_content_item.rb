class PhotoContentItem < ContentItem
  field :caption, type: String
  belongs_to :photo

  def photo_url
    # This needs to be relative to the edition
    photo.attachment.url
  end
end
