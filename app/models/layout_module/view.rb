require  'layout_module'

class LayoutModule
  class View < SimpleDelegator
    def render(name, *args, &block)
      layout_module.partials[name].render(self, *args, &block)
    end

    # Render content within a partial serving as a layout.
    def render_layout(name, *args, &block)
      concat(layout_module.partials[name].render(self, *args, &block))
    end

    def capture(&block)
      view = LayoutModule::CaptureConcat.new(self)
      view.instance_eval(&proc)
    end

    def stylesheet_link_tag(name)
      %Q{<link href="#{name}.css" rel="stylesheet" media="screen" />}
    end

    def javascript_include_tag(name)
      %Q{<script src="#{name}.js" type="text/javascript"></script>}
    end

  end
end
