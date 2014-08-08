@Newstime = @Newstime || {}

class @Newstime.PropertiesPanelView extends Backbone.View

  initialize: (options) ->
    @palette = new Newstime.PaletteView(title: "Properties")
    @palette.attach(@$el)

    @$el.html """
    """

    @palette.show()
