# View layer which manages display and interaction with panels
class @Newstime.MenuLayerView extends Newstime.View

  initialize: (options) ->
    @$el.addClass 'menu-layer-view'

    @menuView = new Newstime.MenuView()
    @$el.append(@menuView.el)

    @bindUIEvents()

  hit: (x, y) ->
    return true if y <= 25 # Own top 25 px.

    return false

  mousedown: (e) ->
    @menuView.trigger 'mousedown', e

  mousemove: (e) ->
    @menuView.trigger 'mousemove', e
