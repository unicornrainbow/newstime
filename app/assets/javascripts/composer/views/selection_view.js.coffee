class @Newstime.SelectionView extends @Newstime.View

  initialize: (options) ->
    @$el.addClass 'selection-view resizable'

    @composer = options.composer || Newstime.composer

    # Add drag handles
    @dragHandles = ['top', 'top-right', 'right', 'bottom-right', 'bottom', 'bottom-left', 'left', 'top-left']
    @dragHandles = _.map @dragHandles, (type) ->
      new Newstime.DragHandle(selection: this, type: type)

    # Attach handles
    handleEls = _.map @dragHandles, (handle) -> handle.el
    @$el.append(handleEls)

    # HACK: Shouldn't be binding direct to the content item model and view
    @contentItemView = options.contentItemView
    @contentItem = @contentItemView.model


    @page = @contentItemView.page
    @pageView = @contentItemView.pageView

    @listenTo @contentItem ,'change', @render
    @listenTo @contentItemView, 'deselect', @remove

    @bindUIEvents()

  getPropertiesView: ->
    @contentItemView.getPropertiesView()

  remove: ->
    unless @destroyed
      @destroyed = true
      @trigger 'destroy', this

      if @contentItemView
        @contentItemView.deselect()

    super


  render: ->
    position = _.pick @contentItem.attributes, 'width', 'height'

    position.top  = @contentItem.get('top')
    position.left = @contentItem.get('left')

    # Apply zoom level
    if @composer.zoomLevel
      zoomLevel = @composer.zoomLevel

      position.height *= zoomLevel
      position.width *= zoomLevel
      position.top *= zoomLevel
      position.left *= zoomLevel

    @$el.css(position)

    this

  paste: (e) ->
    @contentItemView.trigger 'paste', e

  getLeft: ->
    @contentItem.get('left')
    #parseInt(@$el.css('left'))

  getTop: ->
    @contentItem.get('top')
    #parseInt(@$el.css('top'))

  getWidth: ->
    @contentItem.get('width')
    #parseInt(@$el.css('width'))

  getHeight: ->
    @contentItem.get('height')

  keydown: (e) ->
    @contentItemView.trigger 'keydown', e

  dblclick: (e) ->
    @contentItemView.trigger 'dblclick', e

  tap: (e) ->
    unless @tapped
      tapped = =>
        # Single tap should clear selection.
        @tapped = null
        @composer.clearSelection()

      @tapped = setTimeout(tapped, 300)
      # console.log @tapped

    # period = Date.now() - @touchT
    # if period < 300
    #   if @tapped
    #     # dbltap... cancel tap
    #     clearTimeout(@tapped)
    #     @tapped = null
    #   else
    #     tapped = =>
    #       # Single tap should clear selection.
    #       @tapped = null
    #       @composer.clearSelection()
    #
    #     @tapped = setTimeout(tapped, 300)

  doubletap: (e) ->
    if @tapped
      # console.log @tapped
      # dbltap... cancel tap
      clearTimeout(@tapped)
      @tapped = null

    # @contentItemView.trigger 'doubletap', e



  # Detects a hit of the selection
  hit: (x, y) ->
    geometry = @getGeometry()

    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 24 # 2px
    geometry.top -= buffer
    geometry.left -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    ## Detect if corrds lie within the geometry
    geometry.left <= x <= geometry.left + geometry.width &&
      geometry.top <= y <= geometry.top + geometry.height


  getGeometry: ->
    @contentItem.pick('top', 'left', 'height', 'width')

  getBounds: ->
    bounds = @contentItem.pick('top', 'left', 'height', 'width')
    bounds.bottom = bounds.top + bounds.height
    bounds.right = bounds.left + bounds.width
    delete bounds.width
    delete bounds.height
    bounds


  mousedown: (e) ->
    return unless e.button == 0 # Only respond to left button mousedown.

    if @hoveredHandle
      @trackResize @hoveredHandle.type
    else
      geometry = @getGeometry()
      @trackMove(e.x - geometry.left, e.y - geometry.top)

  # `touchstart` is a touch event triggered by the
  # browser

  touchstart: (e) ->
    touch = e.touches[0]
    x = touch.x
    y = touch.y

    # Time when the touch began
    # @touchT = Date.now()

    hitHandle = @hitsDragHandle(x, y)

    if hitHandle
      @trackResize hitHandle
    else
      geometry = @getGeometry()
      @trackMove(x - geometry.left, y - geometry.top)
      # @moved = false # Flag set to see if moved, useful in determining tap

  beginDraw: (x, y) ->
    # TODO: Rewrite this with selection
    # Snap x to grid
    @pageView.collectLeftEdges(@contentItem)
    snapX = @pageView.snapLeft(x)
    if snapX
      x = snapX

    @contentItem.set
      left: x
      top: y
      width: 1 # HACK: Set some initial value for width and height to avoid it not being set.
      height: 1

    @trackResize("bottom-right") # Begin tracking for size

  trackResize: (mode) ->
    @resizing   = true
    @contentItemView.needsReflow = true # TODO: Should use resize event
    @resizeMode = mode

    # Highlight the drag handle
    _.find(@dragHandles, (h) -> h.type == mode).selected()

    switch @resizeMode
      when 'top', 'top-left', 'top-right'
        @pageView.computeTopSnapPoints()

      when 'bottom', 'bottom-left', 'bottom-right'
        @pageView.computeBottomSnapPoints()

        # Get all objects below object that can be moved up and down in unison.
        @attachedItems = @pageView.getAttachedItems(@contentItem)


    switch @resizeMode
      when 'left', 'top-left', 'bottom-left'
        @pageView.collectLeftEdges(@contentItem)

      #when 'right', 'top-right', 'bottom-right'
        #@pageView.collectRightEdges(this)


    @trigger 'tracking', this

  trackMove: (offsetX, offsetY) ->
    @pageView.computeTopSnapPoints()
    @pageView.collectLeftEdges(@contentItem)
    @pageView.collectRightEdges(@contentItem)
    @moving      = true
    @orginalPositionX = @contentItem.get('left')
    @orginalPositionY = @contentItem.get('top')
    @moveOffsetX = offsetX
    @moveOffsetY = offsetY
    @trigger 'tracking', this

  touchmove: (e) ->
    touch = e.touches[0]
    x = touch.x
    y = touch.y

    if @resizing
      switch @resizeMode
        when 'top'          then @dragTop(x, y)
        when 'right'        then @dragRight(x, y)
        when 'bottom'       then @dragBottom(x, y)
        when 'left'         then @dragLeft(x, y)
        when 'top-left'     then @dragTopLeft(x, y)
        when 'top-right'    then @dragTopRight(x, y)
        when 'bottom-left'  then @dragBottomLeft(x, y)
        when 'bottom-right' then @dragBottomRight(x, y)
    else if @moving
      # @moved = true
      @move(x, y)

  touchend: (e) ->
    if @resizing
      @resizing = false
      @resizeMode = null

      @composer.clearVerticalSnapLines() # Ensure vertical snaps aren't showing.
      # Reset drag handles, clearing if they where active
      _.each @dragHandles, (h) -> h.reset()
      @contentItemView.trigger 'resized'

    if @moving
      @moving = false
      # if @moved
      @composer.clearVerticalSnapLines()
      @composer.assignPage(@contentItem, @contentItemView)



    @trigger 'tracking-release', this

  mousemove: (e) ->
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
      @move(e.x, e.y, e.shiftKey)
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

    boxSize = 48

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
    console.log x, y, left, top, boxSize
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


  # Moves based on corrdinates and starting offset
  move: (x, y, shiftKey=false) ->
    x -= @moveOffsetX
    y -= @moveOffsetY

    @composer.moveItem(this, x, y, @orginalPositionX, @orginalPositionY, shiftKey)
    #@pageView.moveItem(this, x, y, @orginalPositionX, @orginalPositionY, shiftKey)

  setSizeAndPosition: (value) ->
    @contentItemView.setSizeAndPosition(value)


  # Resizes based on a top drag
  dragTop: (x, y) ->
    geometry = @getGeometry()
    y = @pageView.snapTop(y)

    @contentItemView.setSizeAndPosition
      top: y
      height: geometry.top - y + geometry.height

  dragRight: (x, y) ->
    @composer.clearVerticalSnapLines()
    geometry = @getGeometry()

    x = Math.min(x, @pageView.getWidth()) # Keep on page
    snapRight = @pageView.snapRight(x) # Snap

    if snapRight
      @composer.drawVerticalSnapLine(snapRight)
      width = snapRight - geometry.left
    else
      width = x - geometry.left

    @contentItemView.setSizeAndPosition
      width: width

  dragBottom: (x, y) ->
    @contentItemView.dragBottom(x, y)

    _.each @attachedItems, ([contentItem, offset]) =>
      contentItem.set
        top: y + offset.offsetTop

  dragLeft: (x, y) ->
    geometry = @getGeometry()
    snapLeft = @pageView.snapLeft(x)
    if snapLeft
      @composer.clearVerticalSnapLines()
      @composer.drawVerticalSnapLine(snapLeft)
      x = snapLeft
    else
      @composer.clearVerticalSnapLines()

    @contentItemView.setSizeAndPosition
      left: x
      width: geometry.left - x + geometry.width


  dragTopLeft: (x, y) ->
    @composer.clearVerticalSnapLines()
    geometry = @getGeometry()
    y        = @pageView.snapTop(y)

    snapLeft = @pageView.snapLeft(x)

    if snapLeft
      @composer.drawVerticalSnapLine(snapLeft)
      x = snapLeft

    @contentItem.set
      left: x
      top: y
      width: geometry.left - x + geometry.width
      height: geometry.top - y + geometry.height

  dragTopRight: (x, y) ->
    @composer.clearVerticalSnapLines()
    geometry  = @getGeometry()
    snapRight = @pageView.snapRight(x)

    if snapRight
      @composer.drawVerticalSnapLine(snapRight)
      width = snapRight - geometry.left
    else
      width     = x - geometry.left

    y = @pageView.snapTop(y)

    @contentItem.set
      top: y
      width: width
      height: geometry.top - y + geometry.height

  dragBottomLeft: (x, y) ->
    @contentItemView.dragBottomLeft(x, y)


  dragBottomRight: (x, y) ->
    @contentItemView.dragBottomRight(x, y)

  mouseup: (e) ->
    if @resizing
      @resizing = false
      @resizeMode = null

      @composer.clearVerticalSnapLines() # Ensure vertical snaps aren't showing.
      # Reset drag handles, clearing if they where active
      _.each @dragHandles, (h) -> h.reset()
      @contentItemView.trigger 'resized'

    if @moving
      @moving = false
      @composer.clearVerticalSnapLines()
      @composer.assignPage(@contentItem, @contentItemView)

    @trigger 'tracking-release', this

  mouseover: (e) ->
    @hovered = true
    @composer.pushCursor @getCursor()

  getCursor: ->
    'default'

  mouseout: (e) ->

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
