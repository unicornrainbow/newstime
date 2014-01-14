class SectionRenderer

  def initialize(section)
    @section = section
  end

  # Return rendered html
  def render
    # To render the section, we need the edition to do interlink, the layout, to
    # render withing, and the pages, which each get rendered.
    @layout  = @section.layout
    @edition = @section.edition
    @pages   = @section.pages

    layout_template = Liquid::Template.parse(@layout.source)
    layout_template.render('yield' => "Output from Page Rendering")
  end

end
