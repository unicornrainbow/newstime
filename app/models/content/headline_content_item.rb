module Content
  class HeadlineContentItem < ContentItem
    field :text, type: String
    field :font_size, type: String
    belongs_to :headline_style
  end
end
