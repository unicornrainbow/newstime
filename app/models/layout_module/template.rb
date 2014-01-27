require 'layout_module'
require 'layout_module/partial'

class LayoutModule
  class Template < Partial
    def render(view, *args, &block)
      view.concat super(view, *args, &block)
    end
  end
end
