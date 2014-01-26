module EditionsHelper
  attr_reader :title, :layout_module, :sections, :publish_date, :edition, :page_content

  def yield_content(&block)
    content = capture(&block)
    view = LayoutModule::CaptureConcat.new(self)
    content = @template.render(view) { content }
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

class LayoutModule::CaptureConcat < SimpleDelegator

  attr_reader :captured_content

  def concat(value)
    @captured_content ||= "".html_safe
    @captured_content << value.html_safe
  end


end
