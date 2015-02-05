#= require ../mixins/canvas_item_view
#
class @Newstime.ContentItemView extends @Newstime.View
  @include Newstime.CanvasItemView

  initialize: (options={}) ->
    @$el.addClass 'content-item-view'

    @composer ?= Newstime.composer
    @edition  ?= @composer.edition

    @outlineView = @composer.outlineViewCollection.add
                     model: @model

    @bindUIEvents()

    # Bind Model Events
    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', @remove

  setElement: (el) ->
    super
    @$el.addClass 'content-item-view'

  render: ->
    @$el.css _.pick @model.attributes, 'width', 'height', 'top', 'left', 'z-index'

  # Sets model values.
  set: ->
    @model.set.apply(@model, arguments)

  # Does a full server render and replaces dom element.
  serverRender: ->
    $.ajax
      method: 'GET'
      url: "#{@edition.url()}/render_content_item.html"
      data:
        composing: true
        content_item: @model.toJSON()
      success: (response) =>
        # Parse response into element.
        el = @_parseHTML(response)

        # Attach and render
        @$el.replaceWith(el)
        @setElement(el)
        @render()

  handelChangePage: ->
    @page = @model.getPage()
    @pageView = @composer.pageViews[@page.cid]

  # Detects a hit of the selection
  hit: (x, y) ->
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

  select: (selectionView) ->
    unless @selected
      @selected = true
      @selectionView = selectionView
      @trigger 'select',
        contentItemView: this
        contentItem: @model

  deselect: ->
    if @selected
      @selected = false
      @selectionView = null
      @trigger 'deselect', this

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

  getBoundry: ->
    @model.getBoundry()

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
        @deselect()
      when 219 # [
        if e.altKey
          if e.shiftKey
            @pageView.sendToBack(@model)
          else
            @pageView.sendBackward(@model)
      when 221 # ]
        if e.altKey
          if e.shiftKey
            @pageView.bringToFront(@model)
          else
            @pageView.bringForward(@model)


  getPropertiesView: ->
    @propertiesView

  getEventChar: (e) ->
    if e.shiftKey
      Newstime.shiftCharKeycodes[e.keyCode]
    else
      Newstime.charKeycodes[e.keyCode]

  stepLeft: ->
    @model.set left: @pageView.stepLeft(@model.get('left'))

  stepRight: ->
    @model.set left: @pageView.stepRight(@model.get('left'))

  # Deletes the content item
  delete: ->
    @deselect() if @selected
    @model.destroy()

  mousedown: (e) ->
    return unless e.button == 0 # Only respond to left button mousedown.

    if @selected
      if e.shiftKey
        # Remove from selection
        @composer.removeFromSelection(this)
    else
      if e.shiftKey
        # Add to selection
        @composer.addToSelection(this)
      else
        @composer.select(this) # TODO: Shift+click with add to selection. alt-click will remove from.

    # Pass mouse down to selection
    @composer.activeSelectionView.trigger 'mousedown', e

    #if @hoveredHandle
      #@trackResize @hoveredHandle.type
    #else
      #geometry = @getGeometry()
      #@trackMove(e.x - geometry.left, e.y - geometry.top)
      #

  mouseup: (e) ->
    #TODO: Need to remove this code, which is no longer used do to selection
    #view

    if @resizing
      @resizing = false
      @resizeMode = null

      @composer.hideVerticalSnapLine() # Ensure vertical snaps aren't showing.
      # Reset drag handles, clearing if they where active
      _.each @dragHandles, (h) -> h.reset()
      @trigger 'resized'

    if @moving?
      @moving = false

    @trigger 'tracking-release', this


  trackResize: (mode) ->
    @resizing   = true
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
      console.log 'hello'
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


  mouseover: (e) ->
    @hovered = true
    #@$el.addClass 'hovered'
    @outlineView.show()
    @composer.pushCursor @getCursor()


  mouseout: (e) ->

    if @hoveredHandle
      @hoveredHandle.trigger 'mouseout', e
      @hoveredHandle = null

    @hovered = false
    #@$el.removeClass 'hovered'
    @outlineView.hide()
    @composer.popCursor()


  # Does an x,y corrdinate intersect a bounding box
  hitBox: (hitX, hitY, boxX, boxY, boxSize) ->
    boxLeft   = boxX - boxSize
    boxRight  = boxX + boxSize
    boxTop    = boxY - boxSize
    boxBottom = boxY + boxSize

    boxLeft <= hitX <= boxRight &&
      boxTop <= hitY <= boxBottom


  # Parses html in to dom element.
  _parseHTML: (html) ->
    div = document.createElement('div')
    div.innerHTML = html
    div.firstChild

  getCursor: ->
    'default'
