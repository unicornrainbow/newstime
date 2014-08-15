# View layer which manages display and interaction with panels
class @Newstime.PanelsView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'panels-view'
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

  mousedown: (e) ->
    # Received a mousedown event, check for a hit and to see if we need to pass
    # on to a panel.

    # Check against panels.
    _.each @panels, (panel) =>
      #@detectHit panel, e.x, e.y
      #
      #
      console.log @detectHit panel, e.x, e.y


      #console.log panel.detectHit e.x, e.y  # Detects hit; Handels hit detection
      #console.log panel, e
      #
      # So, we want to object to have control of what is considered a hit.
      # But what we really want to know is what we hit.


    return true

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
