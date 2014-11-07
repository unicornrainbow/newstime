
class @Newstime.BoundedBoxView extends Backbone.View # ItemView?

  initialize: (options) ->

    @$el.addClass 'selection-view'

    # Add drag handles
    @dragHandles = ['top', 'top-right', 'right', 'bottom-right', 'bottom', 'bottom-left', 'left', 'top-left']
    @dragHandles = _.map @dragHandles, (type) ->
      new Newstime.DragHandle(selection: this, type: type)

    # Attach handles
    handleEls = _.map @dragHandles, (handle) -> handle.el
    @$el.append(handleEls)

    @$el.css _.pick @model.attributes, 'top', 'left', 'width', 'height'

    @bind 'mousedown', @mousedown
    @bind 'mousemove', @mousemove
    @bind 'mouseup',   @mouseup
    @bind 'mouseover', @mouseover
    @bind 'mouseout',  @mouseout
    @bind 'keydown',   @keydown

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

  activate: ->
    @active = true
    @trigger 'activate', this
    @$el.addClass 'resizable'

  deactivate: ->
    @active = false
    @clearEditMode()
    @trigger 'deactivate', this
    @$el.removeClass 'resizable'

  beginSelection: (x, y) -> # TODO: rename beginDraw
    # Snap x to grid
    x = @page.snapLeft(x)

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
