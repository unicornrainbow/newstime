# View layer which manages display and interaction with panels
class @Newstime.PanelLayerView extends @Newstime.View

  events:
    'mousemove': 'dOMMousemove'

  initialize: (options) ->
    @$el.addClass 'panel-layer-view'
    @composer = Newstime.composer
    @panels ?= []

    # Until we have a better means of containg all the application layer, just
    # using this simple means to offset from the top.
    @topOffset = options.topOffset
    @$el.css top: "#{@topOffset}px"

    @bindUIEvents()

  attachPanel: (panel) ->
    # Push onto the panels collection.
    @panels.push panel

    panel.bind 'tracking', @tracking, this
    panel.bind 'tracking-release', @trackingRelease, this

    # Attach it to the dom el
    @$el.append(panel.el)


  # Registers hit, and returns hit panel, should there be one.
  hit: (x, y) ->
    return false if @hidden # Can't be hit if hidden.

    y -= @topOffset

    e =
      x: x
      y: y
    # Received a mousedown event, check for a hit and to see if we need to pass
    # on to a panel.

    # Check against panels.
    # Panel are assumed to be in order from top most first (When selected, a
    # panel is moved to the top visually and in this stack

    panel = _.find @panels, (panel) =>
      @detectHit panel, x, y

    #console.log panel

    if @hovered # Only process events if hovered.
      if panel
        if @hoveredObject != panel
          if @hoveredObject
            @hoveredObject.trigger 'mouseout', e
          @hoveredObject = panel
          @hoveredObject.trigger 'mouseover', e

        return true
      else
        if @hoveredObject
          @hoveredObject.trigger 'mouseout', e
          @hoveredObject = null

        return false

    else
      if panel
        # Defer processing of events until we are declared the hovered object.
        @hoveredObject = panel
        return true
      else
        return false

  detectHit: (panel, x, y) ->
    # Get panel geometry
    geometry = panel.geometry()

    # Expand the geometry by buffer distance in each direction to extend
    # clickable area.
    buffer = 4 # 2px
    geometry.x -= buffer
    geometry.y -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    # Detect if corrds lie within the geometry
    if x >= geometry.x && x <= geometry.x + geometry.width
      if y >= geometry.y && y <= geometry.y + geometry.height
        return true

    return false

  mouseover: (e) ->
    @adjustEventXY(e) # This should be localized to corrds, and isolated to this view. Since this is modifying a shared object, this leaks

    @hovered = true

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

  mouseout: (e) ->
    @adjustEventXY(e)

    @hovered = false

    if @hoveredObject
      @hoveredObject.trigger 'mouseout', e
      @hoveredObject = null


  mousedown: (e) ->
    @adjustEventXY(e)

    if @hoveredObject
      @hoveredObject.trigger 'mousedown', e

  mouseup: (e) ->
    @adjustEventXY(e)

    if @trackingPanel
      @trackingPanel.trigger 'mouseup', e
      return true

    if @hoveredObject
      @hoveredObject.trigger 'mouseup', e

  mousemove: (e) ->
    @adjustEventXY(e)

    if @trackingPanel
      @trackingPanel.trigger 'mousemove', e
      return true

    if @hoveredObject
      @hoveredObject.trigger 'mousemove', e

  dOMMousemove: (e) ->
    # If we receive a dom mousemove here, that means that the capture layer is
    # disengaged, and if the mousemove was over a panel, it did not stop the
    # propogation, or that it is not over a panel at all. In either case, the
    # capture layer should be reengaged so the the mouse event can go to the
    # right place. The panels themseleves should handel mousemove, and cancel
    # propgation to keep the capture layer from being reengaged. This should
    # help with a bug that crops up when the mouseout on the panel is missed or
    # somthing, and the capture layer doesn't reengage. This sort should wash
    # over that, but there is still an underlying issue the should be figured
    # out.
    @hovered = false

    if @hoveredObject
      @hoveredObject.trigger 'mouseout', e
      @hoveredObject = null

    @composer.captureLayerView.engage()
    @composer.unlockScroll()

  adjustEventXY: (e) ->
    e.y -= @topOffset

  tracking: (panel) ->
    @trackingPanel = panel
    @trigger 'tracking', this

  trackingRelease: (panel) ->
    @trackingPanel = null
    @trigger 'tracking-release', this

  # Toggles Visibility
  toggle: ->
    @hidden = !@hidden
    @$el.toggle(!@hidden)
