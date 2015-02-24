# View layer which manages display and interaction with panels
class @Newstime.MenuLayerView extends Newstime.View

  initialize: (options) ->
    @$el.addClass 'menu-layer-view'

    @width = 1184

    @menuView = new Newstime.MenuView()
    @$el.append(@menuView.el)

    @boundry = new Newstime.ComplexBoundry()

    # Draw shape for main menu area
    @mainAreaBoundry = new Newstime.Boundry(top: 0, left: 0, width: @width, height: 25)
    @boundry.addBoundry(@mainAreaBoundry)

    # Draw boundry for testing
    #boundryView = new Newstime.BoundryView(model: @mainAreaBoundry)
    #@$el.append(boundryView.el)


    @bindUIEvents()

  hit: (x, y) ->
    # Check for hit against cutout.
    @boundry.hit(x, y)

    #return true if y <= 25 # Own top 25 px.
    #return false

  mousedown: (e) ->
    @menuView.trigger 'mousedown', e

  mousemove: (e) ->
    @menuView.trigger 'mousemove', e
