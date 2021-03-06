# View layer which manages display and interaction with panels
class @Newstime.MenuLayerView extends Newstime.View

  initialize: (options) ->
    @$el.addClass 'menu-layer-view'

    @attachedViews = []

    @cutout = new Newstime.ComplexBoundry()

    @width = 1184

    # Draw shape for main menu area
    @mainAreaBoundry = new Newstime.Boundry(top: 0, left: 0, width: @width, height: 25)
    @cutout.addBoundry(@mainAreaBoundry)

    @menuView = new Newstime.MenuView()
    @attach(@menuView)

    # Draw boundry for testing
    #boundryView = new Newstime.BoundryView(model: @mainAreaBoundry)
    #@$el.append(boundryView.el)

    @bindUIEvents()

    @bind 'attach', @handelAttach
    @bind 'windowResize', @handelWindowResize

  hit: (x, y) ->
    x -= @menuView.leftOffset
    @cutout.hit(x, y)

  mousedown: (e) ->
    @menuView.trigger 'mousedown', e

  mousemove: (e) ->
    @menuView.trigger 'mousemove', e

  mouseout: (e) ->
    @menuView.trigger 'mouseout', e

  mouseover: (e) ->
    @menuView.trigger 'mouseover', e

  attach: (view) ->
    @attachedViews.push(view)
    @$el.append(view.el)
    view.trigger 'attach'

  handelAttach: ->
    _.each @attachedViews, (v) -> v.trigger 'attach'

  handelWindowResize: ->
    _.each @attachedViews, (v) -> v.trigger 'windowResize'
