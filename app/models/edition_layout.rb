# TODO: Rename to LayoutModule
class EditionLayout

  def initialize(name)
    @name = name
  end

  def render
    template = Tilt.new("#{Rails.root}/vendor/edition_layouts/#{@name}/views/main.html.erb")
    context = EditionLayoutContext.new(title: "San Francisco Record")
    template.render(context) do
      %q{
      <div class="row">
        <div class="col span24">
          Content
        </div>
      </div>
      }
    end
  end

end

class EditionLayoutContext

  attr_accessor :title

  def initialize(opts={})
    @title = opts.delete(:title)
  end

  def stylesheet_link_tag(name)
    %Q{<link href="#{name}.css" rel="stylesheet" media="screen" />}
  end

  def javascript_include_tag(name)
    %Q{<script src="#{name}.js" type="text/javascript"></script>}
  end

  def render(*args)
  end
end
