module EditionsHelper
  attr_reader *[
    :layout_module,
    :edition,
    :section,
    :composing,
    :template_name,
    :title
  ]

  attr_accessor :layouts

  alias :composing? :composing

  def layouts
    @layouts ||= []
  end

  def wrap_with(*args)
    layouts << args
  end

  def yield_content(&block)
    content = capture(&block)

    # Decorate view with layout module particularities.
    view = LayoutModule::View.new(self)

    while layout = layouts.pop
      template_name = layout.shift
      template = layout_module.templates[template_name]
      content = template.render(view, *layout) { content }.html_safe
    end

    concat(content)
  end

  def render(name, *args)
    super(name, *args)
  rescue ActionView::MissingTemplate
    view = LayoutModule::View.new(self)
    template = layout_module.templates[name]
    content = template.render(view, *args).html_safe
    concat(content)
  end

  def composer_stylesheet
    stylesheet_link_tag("composer") + "\n"
  end

  def composer_javascript
    content = content_for(:composer_variables)
    content << javascript_include_tag("composer") + "\n"
  end
end
