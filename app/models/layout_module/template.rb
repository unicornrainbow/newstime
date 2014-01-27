require 'layout_module'
require 'layout_module/partial'

class LayoutModule
  class Template < Partial
    def render(view, *args, &block)
      # Decorate view with layout module particularities.
      view = LayoutModule::View.new(view)
      view.concat super(view, *args, &block)
    end
  end
end
