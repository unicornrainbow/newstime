require  'layout_module'

class LayoutModule
  class Template
    def initialize(layout_module, name)
      @layout_module = layout_module
      @name = name
    end

    def render(view, &block)
      # TODO: Resolve extension and location based on search path and extensions
      # (Should be handled by Tilt)

			view = LayoutModule::View.new(view)

      tilt = Tilt.new("#{@layout_module.root}/views/#{@name}.html.erb")
      tilt.render(view) { view.capture(&block) }
    end
  end
end
