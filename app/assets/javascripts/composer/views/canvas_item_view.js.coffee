class @Newstime.CanvasItemView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'canvas-item-view'

    # Options
    @canvasLayerView = options.canvasLayerView
    @composer = window.composer

    # Page offsets for positioning.
    @pageOffsetLeft = options.pageOffsetLeft
    @pageOffsetTop  = options.pageOffsetTop

    # Add drag handles
    @dragHandles = ['top', 'top-right', 'right', 'bottom-right', 'bottom', 'bottom-left', 'left', 'top-left']
    @dragHandles = _.map @dragHandles, (type) ->
      new Newstime.DragHandle(selection: this, type: type)

    # Attach handles
    handleEls = _.map @dragHandles, (handle) -> handle.el
    @$el.append(handleEls)

    @$el.css
      top: @model.get('top') + @pageOffsetTop
      left: @model.get('left') + @pageOffsetLeft
    @$el.css _.pick @model.attributes, 'width', 'height'

    @bind 'mousedown', @mousedown
    @bind 'mousemove', @mousemove
    @bind 'mouseup',   @mouseup
    @bind 'mouseover', @mouseover
    @bind 'mouseout',  @mouseout
    @bind 'keydown',   @keydown

    # Bind Model Events
    @model.bind 'change', @modelChanged, this
    @model.bind 'destroy', @modelDestroyed, this

  modelChanged: ->
    #@$el.css _.pick @model.changedAttributes(), 'top', 'left', 'width', 'height'

    @$el.css
      top: @model.get('top') + @pageOffsetTop
      left: @model.get('left') + @pageOffsetLeft
    @$el.css _.pick @model.attributes, 'width', 'height'

  modelDestroyed: ->
    # TODO: Need to properly unbind events and allow destruction of view
    @$el.remove()

  # Detects a hit of the selection
  hit: (x, y) ->
    x = x - @pageOffsetLeft
    y = y - @pageOffsetTop

    geometry = @getGeometry()

    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 4 # 2px
    geometry.top -= buffer
    geometry.left -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    ## Detect if corrds lie within the geometry
    geometry.left <= x <= geometry.left + geometry.width &&
      geometry.top <= y <= geometry.top + geometry.height

  activate: ->
    @active = true
    @trigger 'activate', this
    @$el.addClass 'resizable'

  deactivate: ->
    @active = false
    @trigger 'deactivate', this
    @$el.removeClass 'resizable'

  beginSelection: (x, y) -> # TODO: rename beginDraw
    # Snap x to grid
    @page.collectLeftEdges(@model)
    snapX = @page.snapLeft(x)
    if snapX
      x = snapX

    @model.set
      left: x
      top: y

    @activate()
    @trackResize("bottom-right") # Begin tracking for size

  getLeft: ->
    @model.get('left')
    #parseInt(@$el.css('left'))

  getTop: ->
    @model.get('top')
    #parseInt(@$el.css('top'))

  getWidth: ->
    @model.get('width')
    #parseInt(@$el.css('width'))

  getHeight: ->
    @model.get('height')
    #parseInt(@$el.css('height'))

  getGeometry: ->
    @model.pick('top', 'left', 'height', 'width')

  keydown: (e) =>
      switch e.keyCode
        when 8 # del
          if confirm "Are you sure you wish to delete this item?"
            @delete()
          e.stopPropagation()
          e.preventDefault()
        when 37 # left arrow
          @stepLeft()
          e.stopPropagation()
          e.preventDefault()
        when 38 # up arrow
          # TODO: Should handle acceleration
          offset = if e.shiftKey then 20 else 1
          @model.set top: @model.get('top') - offset
          e.stopPropagation()
          e.preventDefault()
        when 39 # right arrow
          @stepRight()
          e.stopPropagation()
          e.preventDefault()
        when 40 # down arrow
          offset = if e.shiftKey then 20 else 1
          @model.set top: @model.get('top') + offset
          e.stopPropagation()
          e.preventDefault()
        when 27 # ESC
          @deactivate()


  getPropertiesView: ->
    @propertiesView


  getEventChar: (e) ->
    if e.shiftKey
      Newstime.shiftCharKeycodes[e.keyCode]
    else
      Newstime.charKeycodes[e.keyCode]

  stepLeft: ->
    @model.set left: @page.stepLeft(@model.get('left'))

  stepRight: ->
    @model.set left: @page.stepRight(@model.get('left'))

  delete: ->
    @model.destroy()


  mousedown: (e) ->
    @adjustEventXY(e)

    return unless e.button == 0 # Only respond to left button mousedown.

    unless @active
      @activate()

    if @hoveredHandle
      @trackResize @hoveredHandle.type
    else
      geometry = @getGeometry()
      @trackMove(e.x - geometry.left, e.y - geometry.top)

  trackResize: (mode) ->
    @resizing   = true
    @resizeMode = mode

    # Highlight the drag handle
    _.find(@dragHandles, (h) -> h.type == mode).selected()

    switch @resizeMode
      when 'top', 'top-left', 'top-right'
        @page.computeTopSnapPoints()

      when 'bottom', 'bottom-left', 'bottom-right'
        @page.computeBottomSnapPoints()


    switch @resizeMode
      when 'left', 'top-left', 'bottom-left'
        @page.collectLeftEdges(@model)

      #when 'right', 'top-right', 'bottom-right'
        #@page.collectRightEdges(this)


    @trigger 'tracking', this

  trackMove: (offsetX, offsetY) ->
    @page.computeTopSnapPoints()
    @moving      = true
    @moveOffsetX = offsetX
    @moveOffsetY = offsetY
    @trigger 'tracking', this

  mousemove: (e) ->
    @adjustEventXY(e)
    if @resizing
      switch @resizeMode
        when 'top'          then @dragTop(e.x, e.y)
        when 'right'        then @dragRight(e.x, e.y)
        when 'bottom'       then @dragBottom(e.x, e.y)
        when 'left'         then @dragLeft(e.x, e.y)
        when 'top-left'     then @dragTopLeft(e.x, e.y)
        when 'top-right'    then @dragTopRight(e.x, e.y)
        when 'bottom-left'  then @dragBottomLeft(e.x, e.y)
        when 'bottom-right' then @dragBottomRight(e.x, e.y)

    else if @moving
      @move(e.x, e.y)

    else if @active
      # Check for hit handles
      hit = @hitsDragHandle(e.x, e.y)
      hit = _.find(@dragHandles, (h) -> h.type == hit)
      if @hoveredHandle && hit
        if @hoveredHandle != hit
          @hoveredHandle.trigger 'mouseout', e
          @hoveredHandle = hit
          @hoveredHandle.trigger 'mouseover', e
      else if @hoveredHandle
        @hoveredHandle.trigger 'mouseout', e
        @hoveredHandle = null

      else if hit
        @hoveredHandle = hit
        @hoveredHandle.trigger 'mouseover', e


  hitsDragHandle: (x, y) ->
    geometry = @getGeometry()

    # TODO: This should all be precalulated
    width   = geometry.width
    height  = geometry.height
    top     = geometry.top
    left    = geometry.left

    right   = left + width
    bottom  = top + height
    centerX = left + width/2
    centerY = top + height/2

    if @hitBox x, y, centerX, top, 8
      return "top"

    # right drag handle hit?
    if @hitBox x, y, right, centerY, 8
      return "right"

    # left drag handle hit?
    if @hitBox x, y, left, centerY, 8
      return "left"

    # bottom drag handle hit?
    if @hitBox x, y, centerX, bottom, 8
      return "bottom"

    # top-left drag handle hit?
    if @hitBox x, y, left, top, 8
      return "top-left"

    # top-right drag handle hit?
    if @hitBox x, y, right, top, 8
      return "top-right"

    # bottom-left drag handle hit?
    if @hitBox x, y, left, bottom, 8
      return "bottom-left"

    # bottom-right drag handle hit?
    if @hitBox x, y, right, bottom, 8
      return "bottom-right"

  adjustEventXY: (e) ->
    # Apply page offset
    e.x -= @pageOffsetLeft
    e.y -= @pageOffsetTop

  # Moves based on corrdinates and starting offset
  move: (x, y) ->
    geometry = @getGeometry()

    # Adjust x corrdinate
    x -= @moveOffsetX
    #x = Math.min(x, @page.getWidth() - @model.get('width')) # Keep on page
    #x = @page.snapLeft(x) # Snap

    y = @page.snapTop(y - @moveOffsetY)
    @model.set
      left: x
      top: y

  # Resizes based on a top drag
  dragTop: (x, y) ->
    geometry = @getGeometry()
    y = @page.snapTop(y)
    @model.set
      top: y
      height: geometry.top - y + geometry.height

  dragRight: (x, y) ->
    geometry = @getGeometry()
    width = x - geometry.left
    width = Math.min(width, @page.getWidth() - @model.get('left')) # Keep on page
    width = @page.snapRight(width) # Snap

    @model.set
      width: width

  dragBottom: (x, y) ->
    geometry = @getGeometry()
    @model.set
      height: @page.snapBottom(y) - geometry.top

  dragLeft: (x, y) ->
    geometry = @getGeometry()
    snapLeft = @page.snapLeft(x)
    if snapLeft
      @composer.showVerticalSnapLine(snapLeft + @page.x())
      x = snapLeft
    else
      @composer.hideVerticalSnapLine()

    @model.set
      left: x
      width: geometry.left - x + geometry.width

  dragTopLeft: (x, y) ->
    geometry = @getGeometry()
    x        = @page.snapLeft(x)
    y        = @page.snapTop(y)
    @model.set
      left: x
      top: y
      width: geometry.left - x + geometry.width
      height: geometry.top - y + geometry.height

  dragTopRight: (x, y) ->
    geometry = @getGeometry()
    width = @page.snapRight(x - geometry.left)
    y = @page.snapTop(y)
    @model.set
      top: y
      width: width
      height: geometry.top - y + geometry.height

  dragBottomLeft: (x, y) ->
    geometry = @getGeometry()
    x = @page.snapLeft(x)
    y = @page.snapBottom(y)
    @model.set
      left: x
      width: geometry.left - x + geometry.width
      height: y - geometry.top

  dragBottomRight: (x, y) ->
    geometry = @getGeometry()
    width    = @page.snapRight(x - geometry.left)
    y        = @page.snapBottom(y)
    @model.set
      width: width
      height: y - geometry.top

  mouseup: (e) ->
    @adjustEventXY(e)

    if @resizing
      @resizing = false
      @resizeMode = null

      @composer.hideVerticalSnapLine() # Ensure vertical snaps aren't showing.
      # Reset drag handles, clearing if they where active
      _.each @dragHandles, (h) -> h.reset()
      @trigger 'resized'

    @moving = false
    @trigger 'tracking-release', this

  mouseover: (e) ->
    @hovered = true
    @$el.addClass 'hovered'
    @composer.pushCursor @getCursor()

  getCursor: ->
    'default'

  mouseout: (e) ->
    @adjustEventXY(e)

    if @hoveredHandle
      @hoveredHandle.trigger 'mouseout', e
      @hoveredHandle = null

    @hovered = false
    @$el.removeClass 'hovered'
    @composer.popCursor()

  # Does an x,y corrdinate intersect a bounding box
  hitBox: (hitX, hitY, boxX, boxY, boxSize) ->
    boxLeft   = boxX - boxSize
    boxRight  = boxX + boxSize
    boxTop    = boxY - boxSize
    boxBottom = boxY + boxSize

    boxLeft <= hitX <= boxRight &&
      boxTop <= hitY <= boxBottom
