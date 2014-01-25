require  'layout_module'

class LayoutModule
  class PartialAccessor

    def initialize(layout_module)
      @layout_module = layout_module
    end

    def [](name)
      Partial.new(@layout_module, name)
    end
  end
end
