module EditionsHelper
  attr_reader :title, :layout_module, :sections, :publish_date, :edition, :page_content

  def yield_content(&block)
    @page_content = capture(&block)

    view = LayoutModule::CaptureConcat.new(self)
    content = @template.render(view) { @page_content }
    concat(view.captured_content.html_safe)

    #view = LayoutModule::View.new(self)
    #content = layout_module.partials['layout'].render(view) { content }
    #concat content.html_safe



    #view = LayoutModule::CaptureConcat.new(self)
    #content = @template.render(view) { content }
    #concat(view.captured_content.html_safe)


    #view = LayoutModule::CaptureConcat.new(self)
    #view.instance_eval(&block)
    #content = view.captured_content.html_safe

    #view.instance_eval(&proc)
    #content = capture(&block)
    # Need to decorate here, to capture output of concat, for injection.
    #content = @template.render(view) { content.html_safe }
    #concat(content.html_safe)
    #@template.render(self, &block).html_safe
    #concat(@template.render(self) { capture(&block).html_safe }.html_safe)
    #concat(@template.render(self) {})
    #@template.render(self).html_safe
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
