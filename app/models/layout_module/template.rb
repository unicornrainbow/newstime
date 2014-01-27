require  'layout_module'

class LayoutModule
  class Template
    def initialize(layout_module, name)
      @layout_module = layout_module
      @name          = name
    end

    def render(view, *args, &block)
      _layouts, view.layouts = view.layouts, []

      # Acquire the tilt template
      tilt = Tilt.new("#{@layout_module.root}/views/#{@name}.html.erb")

      # Capture content from block.
      content = view.capture(&block)

      # Decorate view with layout module particularities.
      view = LayoutModule::View.new(view)

      # Render using the LayoutModule::View wrapped view, injecting the rendered
      # content and passing the args.
      content = tilt.render(view, *args) { content }

      while partial_name = view.layouts.pop
        content = view.layout_module.partials[partial_name].render(view, *args) { content }
      end

      view.concat(content)
      view.layouts = _layouts
    end
  end
end
