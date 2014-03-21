class HeadlineContentItem < ContentItem
  field :text, type: String
  field :font_size, type: String
  field :font_weight, type: String
  field :font_family
  field :font_style
  field :text_align
  field :margin_top
  field :margin_bottom
  field :padding_top
  field :padding_bottom

  belongs_to :headline_style

  def style
    attributes.slice('font_size', 'font_weight', 'font_family', 'font_style', 'text_align', 'margin_top', 'margin_bottom', 'padding_top', 'padding_bottom').map do |k, v|
      "#{k.gsub('_', '-')}: #{v};"
    end.join
  end

end
