module EditionsHelper
  attr_reader :title, :layout_module, :sections, :publish_date, :edition, :composing
  attr_accessor :current_layout

  alias :composing? :composing

  def layouts
    @layouts ||= []
  end

  def yield_content(&block)
    content = capture(&block)

    if template_name = layouts.pop
      view = LayoutModule::CaptureConcat.new(self)
      template = layout_module.templates[template_name]
      template.render(view) { content }
      content = view.captured_content.html_safe
    end

    concat(content)
  end

  def layout(name)
    self.layouts << name
  end

  def composer_stylesheet
    stylesheet_link_tag("composer")
  end

  def composer_javascript
    javascript_include_tag("composer")
  end
end
