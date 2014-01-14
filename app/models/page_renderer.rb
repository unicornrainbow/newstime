class PageRenderer

  def initialize(page)
    @page = page
  end

  # Return rendered html
  def render(params)
    layout_template = Liquid::Template.parse(@page.source)
    layout_template.render(params)
  end

end
