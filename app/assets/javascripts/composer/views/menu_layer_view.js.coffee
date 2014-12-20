# View layer which manages display and interaction with panels
class @Newstime.MenuLayerView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'menu-layer-view'

    # Until we have a better means of containg all the application layer, just
    # using this simple means to offset from the top.
    @topOffset = options.topOffset
    @$el.css top: "#{@topOffset}px"

    @menuView = new Newstime.MenuView()
    @$el.append(@menuView.el)

    @bind 'mousedown', @mousedown

  hit: (x, y) ->
    return true if y <= 25 # Own top 25 px.

    return false

  mousedown: (e) ->
    # TODO: Implement
