module EditionsHelper
  attr_reader :title, :layout_module, :sections, :publish_date, :edition, :composing
  attr_accessor :current_layout

  def layouts
    @layouts ||= []
  end

  def yield_content(&block)
    content = capture(&block)

    _layout = self.layouts.pop
    if _layout
      view = LayoutModule::CaptureConcat.new(self)
      @template.render(view) { content }
      concat(view.captured_content.html_safe)
    else
      concat(content)
    end
  end

  def layout(name)
    self.layouts << layout_module.templates[name]
  end

  # Render content within a partial serving as a layout.
  def yield_to(name)
    self.current_layout = layout_module.partials[name]
  end

  alias :composing? :composing

  def composer_stylesheet
    stylesheet_link_tag("composer")
  end

  def composer_javascript
    javascript_include_tag("composer")
  end
end
