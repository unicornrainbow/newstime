class LayoutModule
  attr_reader :name, :root, :templates, :partials

  SUPPORTED_TEMPLATE_FORMATS = [:erb, :haml, :slim]

  def initialize(name)
    @name = name
    @root = "#{Rails.root}/layouts/#{@name}"
    @templates = TemplateAccessor.new(self)
  end
end
