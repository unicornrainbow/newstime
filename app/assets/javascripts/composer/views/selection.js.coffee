@Newstime = @Newstime || {}

class @Newstime.Selection extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'selection'

    # Add draw handles
    @$el.html """
      <div class="draw-handle top"></div>
      <div class="draw-handle bottom"></div>
      <div class="draw-handle right"></div>
      <div class="draw-handle left"></div>
      <div class="draw-handle top-left"></div>
      <div class="draw-handle bottom-left"></div>
      <div class="draw-handle top-right"></div>
      <div class="draw-handle bottom-right"></div>
    """

    @bind 'mousedown', @mousedown

  activate: ->
    @active = true
    @$el.addClass 'resizable'

  deactivate: ->
    @active = false
    @$el.removeClass 'resizable'

  beginSelection: (anchorX, anchorY) ->
    #@trackingSelection = true

    @activate()

    @anchorX = anchorX
    @anchorY = anchorY

    @$el.css
      left: @anchorX
      top: @anchorY


  width: ->
    parseInt(@$el.css('width'))

  height: ->
    parseInt(@$el.css('height'))

  x: ->
    parseInt(@$el.css('left'))

  y: ->
    parseInt(@$el.css('top'))

  geometry: ->
    x: @x()
    y: @y()
    width: @width()
    height: @height()

  # Detects a hit of the selection
  hit: (x, y) ->

    geometry = @geometry()

    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 4 # 2px
    geometry.x -= buffer
    geometry.y -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    ## Detect if corrds lie within the geometry
    if x >= geometry.x && x <= geometry.x + geometry.width
      if y >= geometry.y && y <= geometry.y + geometry.height
        return true

    return false

  mousedown: (e) ->
    x = e.x
    y = e.y

    geometry = @geometry()

    # If active, check against the drag handles
    if @active
      # top-left drag handle hit?
      if x >= geometry.x - 8 && x <= geometry.x + 8
        if y >= geometry.y - 8 && y <= geometry.y + 8
          console.log "Top left drag handle hit"
          # TODO: Begin dragging
          return false # Cancel event

      # top-right drag handle hit?
      if x >= geometry.x + geometry.width - 8 && x <= geometry.x + geometry.width + 8
        if y >= geometry.y - 8 && y <= geometry.y + 8
          console.log "Top right drag handle hit"
          return false # Cancel event

    return true
