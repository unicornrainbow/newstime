# layout_module = LayoutModule.new('sfrecord/v1')
# template = layout_module.templates['main']
# template.render(title: "San Francisco Record")


# TODO: Need to guard against recursion in layout rendering! Limit depth

class LayoutModule

  attr_reader :name, :root, :templates, :partials

  def initialize(name)
    @name = name
    @root = "#{Rails.root}/layouts/#{@name}"
    @templates = TemplateAccessor.new(self)
    @partials = PartialAccessor.new(self)
  end

  class TemplateAccessor

    def initialize(layout_module)
      @layout_module = layout_module
    end

    def [](name)
      Template.new(@layout_module, name)
    end

  end

  class PartialAccessor

    def initialize(layout_module)
      @layout_module = layout_module
    end

    def [](name)
      Partial.new(@layout_module, name)
    end

  end

  class Template

    def initialize(layout_module, name)
      @layout_module = layout_module
      @name = name
    end

    def render(*args)
      context = Context.new(@layout_module, *args)

      # TODO: Resolve extension and location based on search path and extensions
      # (Should be handled by Tilt)

      tilt = Tilt.new("#{@layout_module.root}/views/#{@name}.html.erb")
      tilt.render(context) do
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

  class Partial

    def initialize(layout_module, name)
      @layout_module = layout_module
      @name = name
    end

    def render(*args)
      context = Context.new(@layout_module, *args)

      # TODO: Resolve extension and location based on search path and extensions
      # (Should be handled by Tilt)

      # Prefixed last segment of name with an underscore by convention.
      segments = @name.split('/')
      segments[-1] = "_" << segments[-1]
      @name = segments.join('/')

      tilt = Tilt.new("#{@layout_module.root}/views/#{@name}.html.erb")
      tilt.render(context) do
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

  class Context
    attr_reader :layout_module

    attr_accessor :title

    def initialize(layout_module, opts={})
      @layout_module = layout_module
      @title = opts.delete(:title)
    end

    def stylesheet_link_tag(name)
      %Q{<link href="#{name}.css" rel="stylesheet" media="screen" />}
    end

    def javascript_include_tag(name)
      %Q{<script src="#{name}.js" type="text/javascript"></script>}
    end

    def render(name, *args)
      layout_module.partials[name].render(*args)
    end
  end

end
