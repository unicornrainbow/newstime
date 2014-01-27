module EditionsHelper
  attr_reader :title, :layout_module, :sections, :publish_date, :edition, :composing

  attr_accessor :layouts

  alias :composing? :composing

  def layouts
    @layouts ||= []
  end

  # TODO: rename to push_layout
  def layout(name)
    layouts << name
  end

  def yield_content(&block)
    content = capture(&block)

    # TODO: loop through layouts
    while template_name = layouts.pop
      view = LayoutModule::CaptureConcat.new(self)
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
