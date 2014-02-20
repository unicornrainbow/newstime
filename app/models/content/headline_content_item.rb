class Content::HeadlineContentItem < ContentItem
  field :text, type: String
  belongs_to :headline_style
end
