class PhotoContentItem < ContentItem
  field :caption, type: String
  belongs_to :photo

  def photo_url
    # This needs to be relative to the edition
    #photo.attachment.url
  end

  def edition_relative_url_path
    photo.try(:edition_relative_url_path)
  end

end
