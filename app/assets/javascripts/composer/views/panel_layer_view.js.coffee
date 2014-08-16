# View layer which manages display and interaction with panels
class @Newstime.PanelLayerView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'panel-layer-view'
    @panels ?= []

    # Until we have a better means of containg all the application layer, just
    # using this simple means to offset from the top.
    @topOffset = options.topOffset
    @$el.css top: "#{@topOffset}px"


  attachPanel: (panel) ->
    # Push onto the panels collection.
    @panels.push panel

    # Attach it to the dom el
    @$el.append(panel.el)

  # Registers hit, and returns hit panel, should there be one.
  hit: (x, y) ->
    # Received a mousedown event, check for a hit and to see if we need to pass
    # on to a panel.

    # Check against panels.
    # Panel are assumed to be in order from top most first (When selected, a
    # panel is moved to the top visually and in this stack

    panel = _.find @panels, (panel) =>
      @detectHit panel, x, y

    return panel

  detectHit: (panel, x, y) ->
    # Get panel geometry
    geometry = panel.geometry()

    # Adjust for top offset, which currently isn't considered in panel gemotry
    # (but should be)
    geometry.y = geometry.y - @topOffset

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

    #console.log panel.x(), panel.y() - @topOffset
    #console.log panel.width(), panel.height()
