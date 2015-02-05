class @Newstime.MultiSelectionView extends @Newstime.View

  initialize: (options={}) ->
    @$el.addClass 'selection-view resizable'

    @composer = options.composer || Newstime.composer

    @selectedViews = []
    @page = null

    # Add drag handles
    @dragHandles = ['top', 'top-right', 'right', 'bottom-right', 'bottom', 'bottom-left', 'left', 'top-left']
    @dragHandles = _.map @dragHandles, (type) ->
      new Newstime.DragHandle(selection: this, type: type)

    # Attach handles
    handleEls = _.map @dragHandles, (handle) -> handle.el
    @$el.append(handleEls)

    @bindUIEvents()

  render: ->
    position = @getPosition()

    ## Apply zoom level
    if @composer.zoomLevel
      zoomLevel = @composer.zoomLevel

      position.height *= zoomLevel
      position.width *= zoomLevel
      position.top *= zoomLevel
      position.left *= zoomLevel

    @$el.css(position)

  getPropertiesView: ->
    null # TODO: Create a propeties panel view

  keydown: (e) ->
    switch e.keyCode
      when 71 # g
        @createGroup() if e.altKey

      when 27 # ESC
        @composer.clearSelection()

  createGroup: ->
    # Create a new GroupView
    groupView = @composer.groupViewCollection.add({})

    # Until we get to isolation mode, the context is the canvas.
    context = @composer.canvas

    # Put views to be grouped in proper stacking order based on page->z-index
    sorted = @selectedViews.sort (a, b) ->
      if a.pageView.model.get('number') != b.pageView.model.get('number')
        a.pageView.model.get('number') - b.pageView.model.get('number')
      else if a.model.get('z-index') != b.model.get('z-index')
        a.model.get('z-index') - b.model.get('z-index')

    # Get the index to insert the group at from first item
    index = _.first(sorted).model.get('z-index')

    # Remove all of the view to be group, keep in order
    # Push views into group according to order
    _.each sorted, (view) ->
      context.removeCanvasItem(view)
      groupView.addCanvasItem(view)

    # Add group to canvas
    #context.insertAt(index, groupView)
    context.addCanvasItem(groupView)

    # Select group
    @composer.select(groupView)

  # Detects a hit of the selection
  hit: (x, y) ->
    @selection.hit(x, y)

  destroy: ->
    @remove()

  mousedown: (e) ->
    return unless e.button == 0 # Only respond to left button mousedown.

    if @hoveredHandle
      @trackResize @hoveredHandle.type
    else
      position = @getPosition()
      @trackMove(e.x - position.left, e.y - position.top)

       #OK, so just a note, but looks like moveing an object is actually a
       #feature of the canvas view layer, which should on each move, figure out
       #which to query into to check against snap points, and infact, can do
       #this against multi pages, and even other objects, and will also need to
       #do similar for highlighting snap points.

  trackMove: (offsetX, offsetY) ->
    #@pageView.computeTopSnapPoints()
    #@pageView.collectLeftEdges(@model)
    #@pageView.collectRightEdges(@model)
    @moving      = true

    position = @getPosition()
    @orginalPositionX = position.left
    @orginalPositionY = position.top
    @moveOffsetX = offsetX
    @moveOffsetY = offsetY
    @trigger 'tracking', this


  mousemove: (e) ->
    #@adjustEventXY(e)
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


  # Moves based on corrdinates and starting offset
  move: (x, y, shiftKey=false) ->
    x -= @moveOffsetX
    y -= @moveOffsetY

    @composer.moveItem(this, x, y, @orginalPositionX, @orginalPositionY, shiftKey)

  getBounds: ->
    bounds = _.clone(@getPosition())
    bounds.bottom = bounds.top + bounds.height
    bounds.right = bounds.left + bounds.width
    delete bounds.width
    delete bounds.height
    bounds


  mouseup: (e) ->
    if @resizing
      @resizing = false
      @resizeMode = null

      @composer.clearVerticalSnapLines() # Ensure vertical snaps aren't showing.
      # Reset drag handles, clearing if they where active
      _.each @dragHandles, (h) -> h.reset()
      @canvasItemView.trigger 'resized'

    if @moving
      @moving = false

      @composer.clearVerticalSnapLines()

    @trigger 'tracking-release', this


  mouseover: (e) ->
    @hovered = true
    @composer.pushCursor @getCursor()

  mouseout: (e) ->
    @hovered = false
    @composer.popCursor()

  getCursor: ->
    'default'

  addView: (view) ->
    @selectedViews.push(view)
    @render()

  getPosition: ->
    @calculatePosition()
    @position

  calculatePosition: ->
    models = _.pluck @selectedViews, 'model'

    top = models[0].get('top')
    left = models[0].get('left')
    bottom = 0
    right = 0

    _.each models, (model) ->
      # TODO: Need to take into consideration page position
      page = model.getPage() # Need to have access to page offsets at the model
      pageOffsetTop  = page.get('offset_top') || 0
      pageOffsetLeft = page.get('offset_left') || 0

      top = Math.min(model.get('top') + pageOffsetTop, top)
      left  = Math.min(model.get('left') + pageOffsetLeft, left)
      bottom = Math.max(model.get('top') + model.get('height') + pageOffsetTop, bottom)
      right = Math.max(model.get('left') + model.get('width') + pageOffsetLeft, right)

    @position =
      top: top
      left: left
      height: bottom - top
      width: right - left

    # TODO: Use top, left, bottom, right for bounding boxes.
    # Create Bounding box class.

    # And expended position bounding box used for hit detection.
    @expandedPosition = @addBuffer(@position, 4)


  # Detects a hit of the selection
  hit: (x, y) ->
    @hitsBoundingBox(@expandedPosition, x, y)

  # Expand the bounding box by buffer distance in each direction to extend
  # clickable area.
  addBuffer: (box, buffer) ->
    box = _.clone(box)

    box.top -= buffer
    box.left -= buffer
    box.width += buffer*2
    box.height += buffer*2

    box

  hitsBoundingBox: (box, x, y) ->
    ## Detect if corrds lie within the geometry
    box.left <= x <= box.left + box.width &&
      box.top <= y <= box.top + box.height

  setSizeAndPosition: (value) ->
    models = _.pluck @selectedViews, 'model'

    _.each models, (model) =>
      topOffset = model.get('top') - @position.top
      leftOffset = model.get('left') - @position.left

      model.set
        top: value.top + topOffset
        left: value.left + leftOffset
    @calculatePosition()
    @render()
