require  'layout_module'

class LayoutModule
  class Context
    attr_reader :layout_module

    attr_accessor :title, :sections

    def initialize(layout_module, opts={})
      @opts = @opts || {}
      @layout_module = layout_module
      @title = opts[:title]
      @sections = opts[:sections]
    end

    def stylesheet_link_tag(name)
      %Q{<link href="#{name}.css" rel="stylesheet" media="screen" />}
    end

    def javascript_include_tag(name)
      %Q{<script src="#{name}.js" type="text/javascript"></script>}
    end

    def link_to(name, path)
      %Q{<a href="#{path}">#{name}</a>}
    end

    def render(name, *args)
      layout_module.partials[name].render(self, *args)
    end

    def cache(*args)
      yield # Mock implementation.
    end
  end
end
