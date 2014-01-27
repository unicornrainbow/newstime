module EditionsHelper
  attr_reader :layout_module, :edition, :composing

  attr_accessor :layouts

  alias :composing? :composing

  def layouts
    @layouts ||= []
  end

  def push_layout(name)
    layouts << name
  end

  def yield_content(&block)
    content = capture(&block)

    # Decorate view with layout module particularities.
    view = LayoutModule::View.new(self)

    while template_name = layouts.pop
      view = LayoutModule::CaptureConcat.new(view)
      template = layout_module.templates[template_name]
      template.render(view) { content }
      content = view.captured_content.html_safe
    end

    concat(content)
  end

  def composer_stylesheet
    stylesheet_link_tag("composer")
  end

  def composer_javascript
    javascript_include_tag("composer")
  end
end
