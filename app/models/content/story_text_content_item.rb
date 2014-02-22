module Content
  class StoryTextContentItem < ContentItem
    field :columns, type: Integer, default: 1

    belongs_to :story
  end
end
