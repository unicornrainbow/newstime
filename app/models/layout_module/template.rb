require  'layout_module'

class LayoutModule
  class Template
    def initialize(layout_module, name)
      @layout_module = layout_module
      @name = name
    end

    def render(view, *args, &block)
      # TODO: Resolve extension and location based on search path and extensions
      # (Should be handled by Tilt)
      #
      content = view.capture(&block)

      view = LayoutModule::View.new(view)
      tilt = Tilt.new("#{@layout_module.root}/views/#{@name}.html.erb")
      tilt.render(view, *args) { content }
      #tilt.render(view, *args) { view.capture(&block) }

      #tilt.render(view, &block)
      #if block_given?
        #tilt.render(view, *args, &block) # { capture(&block) }
      #else
        #tilt.render(view, *args)
      #end
      #tilt.render(view, *args, &block)
    end
  end
end
