module EditionsHelper
  attr_reader :title, :layout_module, :sections, :publish_date, :edition, :composing
  attr_accessor :current_layout

  def yield_content(&block)
    view = LayoutModule::CaptureConcat.new(self)
    content = @template.render(view) { capture(&block) }
    concat(view.captured_content.html_safe)
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
