class TextAreaContentItem < ContentItem
  field :columns,       type: Integer, default: 1 # How many columns to render text as.
  field :text,          type: String, default: ""
  field :rendered_html, type: String
  field :overrun_html,  type: String
  field :rendered_at,   type: DateTime
  field :by_line,       type: String
  field :show_by_line,  type: Boolean, default: false
  field :story_title,   type: String  # String key used for lacing text areas together
  field :overflow_input_text, type: String

  # Width of each text column based on width, column count and gutter width.
  def text_column_width
    (width - (columns - 1) * gutter_width) / columns
  end

  def gutter_width
    page.gutter_width # Derived from page
  end

  def typeset!
    TextAreaTypesetter.new(self).typeset!
  end

end
