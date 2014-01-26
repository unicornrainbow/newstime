module EditionsHelper
  attr_reader :title, :layout_module, :sections, :publish_date

  def yield_content(&block)
    @template.render(self, &block).html_safe
  end
end
