module EditionsHelper
  attr_reader :title, :layout_module, :sections, :publish_date, :edition

  def yield_content(&block)
    view = LayoutModule::CaptureConcat.new(self)
    content = @template.render(view) { capture(&block) }
    concat(view.captured_content.html_safe)
  end

  def composing?
    @composing
  end

  def composer_stylesheet
    stylesheet_link_tag("composer")
  end

  def composer_javascript
    javascript_include_tag("composer")
  end
end
