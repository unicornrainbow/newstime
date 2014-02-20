module Content
  class HeadlineContentItem < ContentItem
    field :text, type: String
    belongs_to :headline_style
  end
end
