module EditionsHelper
  attr_reader :layout_module, :edition, :composing, :template_name

  attr_accessor :layouts

  alias :composing? :composing

  def layouts
    @layouts ||= []
  end

  def wrap_with(name)
    layouts << name
  end

  def yield_content(&block)
    content = capture(&block)

    # Decorate view with layout module particularities.
    view = LayoutModule::View.new(self)

    while template_name = layouts.pop
      template = layout_module.templates[template_name]
      content = template.render(view) { content }.html_safe
    end

    concat(content)
  end

  def composer_stylesheet
    stylesheet_link_tag("composer") + "\n"
  end

  def composer_javascript
    javascript_include_tag("composer") + "\n"
  end
end
