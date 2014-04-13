object @content_item

# Content Item Base Attributes
attributes *%w(
  sequence
  height
)

# Story Text Attributes
attributes :columns

# Photo Attributes
attributes :photo

child(:story) do
  extends 'stories/story_attributes'
end
