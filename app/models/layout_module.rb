class LayoutModule
  attr_reader :name, :root, :templates, :partials

  SUPPORTED_TEMPLATE_FORMATS = [:erb, :haml, :slim]

  def initialize(name)
    @name = name
    @root = MEDIA_MODULES[@name]
    @templates = TemplateAccessor.new(self)
  end
end
