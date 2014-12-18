#class @Newstime.CanvasViewItemSelectionView extends Backbone.View
class @Newstime.SelectionView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'selection-view resizable'

    @selection = options.selection
    @composer = options.composer

    # Add drag handles
    @dragHandles = ['top', 'top-right', 'right', 'bottom-right', 'bottom', 'bottom-left', 'left', 'top-left']
    @dragHandles = _.map @dragHandles, (type) ->
      new Newstime.DragHandle(selection: this, type: type)

    # Attach handles
    handleEls = _.map @dragHandles, (handle) -> handle.el
    @$el.append(handleEls)

    # HACK: Shouldn't be binding direct to the content item model and view
    @model = @contentItem = @selection.contentItem
    @canvasItemView = @contentItemView = @selection.contentItemView # TODO: Should be canvasItemSelection (As the selection type)

    @canvasItemView.bind 'deselect', @destroy, this

    @page = @contentItemView.page
    @pageView = @contentItemView.pageView

    @pageOffsetLeft = @contentItemView.pageOffsetLeft
    @pageOffsetTop  = @contentItemView.pageOffsetTop


    @contentItem.bind 'change', @render, this

    @bind 'mousedown', @mousedown
    @bind 'mousemove', @mousemove
    @bind 'mouseover', @mouseover
    @bind 'mouseout', @mouseout
    @bind 'mouseup', @mouseup
    @bind 'paste', @paste
    @bind 'keydown',   @keydown
    @bind 'dblclick',  @dblclick

    @render()

  destroy: ->
    unless @destroyed
      @destroyed = true
      @unbind()

      @trigger 'destroy', this

      if @canvasItemView
        @canvasItemView.unbind 'deselect', @destroy, this
        @canvasItemView.deselect()

      @$el.remove()

  render: ->
    position = _.pick @contentItem.attributes, 'width', 'height'

    position.top = @contentItem.get('top')
    position.top += @pageOffsetTop

    position.left = @contentItem.get('left')
    position.left += @pageOffsetLeft

    # Apply zoom level
    if @composer.zoomLevel
      zoomLevel = @composer.zoomLevel

      position.height *= zoomLevel
      position.width *= zoomLevel
      position.top *= zoomLevel
      position.left *= zoomLevel

    @$el.css(position)

  paste: (e) ->
    @canvasItemView.trigger 'paste', e

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

  keydown: (e) ->
    @contentItemView.trigger 'keydown', e

  dblclick: (e) ->
    @contentItemView.trigger 'dblclick', e

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


  getGeometry: ->
    @model.pick('top', 'left', 'height', 'width')

  mousedown: (e) ->
    @adjustEventXY(e)

    return unless e.button == 0 # Only respond to left button mousedown.

    if @hoveredHandle
      @trackResize @hoveredHandle.type
    else
      geometry = @getGeometry()
      @trackMove(e.x - geometry.left, e.y - geometry.top)


  beginDraw: (x, y) ->
    # TODO: Rewrite this with selection
    # Snap x to grid
    @pageView.collectLeftEdges(@model)
    snapX = @pageView.snapLeft(x)
    if snapX
      x = snapX

    @model.set
      left: x
      top: y

    @trackResize("bottom-right") # Begin tracking for size

  trackResize: (mode) ->
    @resizing   = true
    @canvasItemView.needsReflow = true # TODO: Should use resize event
    @resizeMode = mode

    # Highlight the drag handle
    _.find(@dragHandles, (h) -> h.type == mode).selected()

    switch @resizeMode
      when 'top', 'top-left', 'top-right'
        @pageView.computeTopSnapPoints()

      when 'bottom', 'bottom-left', 'bottom-right'
        @pageView.computeBottomSnapPoints()


    switch @resizeMode
      when 'left', 'top-left', 'bottom-left'
        @pageView.collectLeftEdges(@model)

      #when 'right', 'top-right', 'bottom-right'
        #@pageView.collectRightEdges(this)


    @trigger 'tracking', this

  trackMove: (offsetX, offsetY) ->
    @pageView.computeTopSnapPoints()
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

    else
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

    boxSize = 8

    if @composer.zoomLevel
      # Compensate box size for zoom level
      boxSize /= @composer.zoomLevel

    if @hitBox x, y, centerX, top, boxSize
      return "top"

    # right drag handle hit?
    if @hitBox x, y, right, centerY, boxSize
      return "right"

    # left drag handle hit?
    if @hitBox x, y, left, centerY, boxSize
      return "left"

    # bottom drag handle hit?
    if @hitBox x, y, centerX, bottom, boxSize
      return "bottom"

    # top-left drag handle hit?
    if @hitBox x, y, left, top, boxSize
      return "top-left"

    # top-right drag handle hit?
    if @hitBox x, y, right, top, boxSize
      return "top-right"

    # bottom-left drag handle hit?
    if @hitBox x, y, left, bottom, boxSize
      return "bottom-left"

    # bottom-right drag handle hit?
    if @hitBox x, y, right, bottom, boxSize
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
    #x = Math.min(x, @pageView.getWidth() - @model.get('width')) # Keep on page
    #x = @pageView.snapLeft(x) # Snap

    y = @pageView.snapTop(y - @moveOffsetY)

    @canvasItemView.setSizeAndPosition
      left: x
      top: y

  # Resizes based on a top drag
  dragTop: (x, y) ->
    geometry = @getGeometry()
    y = @pageView.snapTop(y)

    @canvasItemView.setSizeAndPosition
      top: y
      height: geometry.top - y + geometry.height

  dragRight: (x, y) ->
    geometry = @getGeometry()
    width = x - geometry.left
    width = Math.min(width, @pageView.getWidth() - @model.get('left')) # Keep on page
    width = @pageView.snapRight(width) # Snap

    @canvasItemView.setSizeAndPosition
      width: width

  dragBottom: (x, y) ->
    geometry = @getGeometry()

    height = @pageView.snapBottom(y) - geometry.top

    @canvasItemView.setSizeAndPosition
      height: height

  dragLeft: (x, y) ->
    geometry = @getGeometry()
    snapLeft = @pageView.snapLeft(x)
    if snapLeft
      @composer.showVerticalSnapLine(snapLeft + @pageView.x())
      x = snapLeft
    else
      @composer.hideVerticalSnapLine()

    @canvasItemView.setSizeAndPosition
      left: x
      width: geometry.left - x + geometry.width


  dragTopLeft: (x, y) ->
    geometry = @getGeometry()
    x        = @pageView.snapLeft(x)
    y        = @pageView.snapTop(y)
    @canvasItemView.setSizeAndPosition
      left: x
      top: y
      width: geometry.left - x + geometry.width
      height: geometry.top - y + geometry.height

  dragTopRight: (x, y) ->
    geometry = @getGeometry()
    width = @pageView.snapRight(x - geometry.left)
    y = @pageView.snapTop(y)
    @canvasItemView.setSizeAndPosition
      top: y
      width: width
      height: geometry.top - y + geometry.height

  dragBottomLeft: (x, y) ->
    geometry = @getGeometry()
    x = @pageView.snapLeft(x)
    y = @pageView.snapBottom(y)

    @canvasItemView.setSizeAndPosition
      left: x
      width: geometry.left - x + geometry.width
      height: y - geometry.top

  dragBottomRight: (x, y) ->
    geometry = @getGeometry()
    width    = @pageView.snapRight(x - geometry.left)
    y        = @pageView.snapBottom(y)

    @canvasItemView.setSizeAndPosition
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
      @canvasItemView.trigger 'resized'

    @moving = false
    @trigger 'tracking-release', this

  mouseover: (e) ->
    @hovered = true
    @composer.pushCursor @getCursor()

  getCursor: ->
    'default'

  mouseout: (e) ->
    @adjustEventXY(e)

    if @hoveredHandle
      @hoveredHandle.trigger 'mouseout', e
      @hoveredHandle = null

    @hovered = false
    #@$el.removeClass 'hovered'
    @composer.popCursor()


  # Does an x,y corrdinate intersect a bounding box
  hitBox: (hitX, hitY, boxX, boxY, boxSize) ->
    boxLeft   = boxX - boxSize
    boxRight  = boxX + boxSize
    boxTop    = boxY - boxSize
    boxBottom = boxY + boxSize

    boxLeft <= hitX <= boxRight &&
      boxTop <= hitY <= boxBottom
