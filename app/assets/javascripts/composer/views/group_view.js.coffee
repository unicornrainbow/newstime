#= require ../views/canvas_item_view
#
#  A group view as an implementation of canvas item view. It represents a group
#  as it appears on, and interacts, with the canvas.
#
class @Newstime.GroupView extends @Newstime.CanvasItemView

  className: 'group-view'

  initializeCanvasItem: (options={}) ->
    @contentItemViewsArray = [] # Array of content items views in z-index order.


    @leftBorder = @model.get('left_border')
    if @leftBorder
      @$el.addClass 'group-left-border'

  @getter 'uiLabel', -> 'Group'

  measurePosition: ->
    @contentItems = _.pluck @contentItemViewsArray, 'model'
    first = _.first(@contentItems)
    if first?
      boundry =  first.getBoundry()

      top = boundry.top
      left = boundry.left
      bottom = boundry.bottom
      right = boundry.right

      _.each @contentItems, (contentItem) ->
        boundry = contentItem.getBoundry()

        top = Math.min(top, boundry.top)
        left = Math.min(left, boundry.left)
        bottom = Math.max(bottom, boundry.bottom)
        right = Math.max(right, boundry.right)

      boundry = new Newstime.Boundry(top: top, left: left, bottom: bottom, right: right)
      @model.set _.pick boundry, 'top', 'left', 'width', 'height'

  mousedown: (e) ->
    return unless e.button == 0 # Only respond to left button mousedown.

    unless @selected
      if e.shiftKey
        # Add to selection
        @composer.addToSelection(this)
      else
        @composer.select(this) # TODO: Shift+click with add to selection. alt-click will remove from.
    else
      if e.shiftKey
        # Remove from selection
        @composer.removeFromSelection(this)

    # Pass mouse down to selection
    @composer.activeSelectionView.trigger 'mousedown', e

  keydown: (e) =>
    switch e.keyCode
      when 85 # u
        @ungroup() if e.altKey
      else
        super(e)

  ungroup: ->
    contentItems = @contentItemViewsArray.slice(0) # Clone array of items.
    _.each contentItems.reverse(), (canvasItem) =>
      @removeCanvasItem(canvasItem)
      @composer.canvas.addCanvasItem(canvasItem)

    @composer.canvas.removeCanvasItem(this)
    @deselect()

    @composer.select.apply(@composer, contentItems)

    @composer.deleteQueue.push @model # Push model onto delete queue for destruction with next save.
    @remove() # Remove view

  delete: ->
    # Delete group contents as well.
    contentItems = @contentItemViewsArray.slice(0) # Clone array of items.
    _.each contentItems, (canvasItem) =>
      canvasItem.delete()
    super

  mouseover: (e) ->
    @hovered = true
    @outlineView.show()
    @composer.pushCursor @getCursor()

  mouseout: (e) ->
    if @hoveredHandle
      @hoveredHandle.trigger 'mouseout', e
      @hoveredHandle = null

    @hovered = false
    @outlineView.hide()
    @composer.popCursor()

  # Adds view to group.
  addCanvasItem: (view, options={}) ->
    viewBoundry = view.model.getBoundry()

    unless options.reattach

      # If this is the first view in the group
      if @contentItemViewsArray.length == 0
        # clone the boundry
        @model.set _.pick viewBoundry, 'top', 'left', 'width', 'height'

        # zero position of element
        view.model.set(top: 0, left: 0)
      else
        # Union boundry into group
        groupBoundry = @getBoundry()
        newBoundry = groupBoundry.union(viewBoundry)

        @_setBoundry(newBoundry)

        # Subtract group offset from element offset.
        view.model.set
          top: viewBoundry.top - newBoundry.top
          left: viewBoundry.left - newBoundry.left

    @contentItemViewsArray.push(view)
    @$el.append(view.el)
    view.groupView = this

    @model.addItem(view.model)

    if view instanceof Newstime.TextAreaView
      @model.set 'story_title', view.model.get('story_title') # HACK: Need to make sure this stays in sync and is updated...

  removeCanvasItem: (canvasItemView) ->

    index = @contentItemViewsArray.indexOf(canvasItemView)

    if index == -1
      throw "Couldn't find canvas item."

    @contentItemViewsArray.splice(index, 1)
    canvasItemView.groupView = null
    canvasItemView.$el.detach()

    groupBoundry = @getBoundry()

    canvasItemView.model.set
      top: groupBoundry.top + canvasItemView.model.top
      left: groupBoundry.left + canvasItemView.model.left

    # TODO: Reapply position for group view

    # Update z-indexs
    #@updateZindexs()

    canvasItemView.model.unset('group_id')

  toggleLeftBorder: ->
    @leftBorder = @model.get('left_border')

    if @leftBorder
      @removeLeftBorder()
    else
      @addLeftBorder()

  # Add Left Border
  addLeftBorder: ->
    @model.set 'left_border', true
    @leftBorder = true

    @$el.addClass 'group-left-border'

    # For each item, push in 15px (1px add for border, total of 16px)
    _.each @contentItemViewsArray, (contentItemView) ->
      if contentItemView instanceof Newstime.TextAreaView
        contentItemView.needsReflow = true

      model = contentItemView.model
      left = model.get('left')
      if left < 15
        delta = 16 - left
        model.set
          left: 15
          width: model.get('width') - delta

      if contentItemView instanceof Newstime.TextAreaView
        contentItemView.reflow()


  # Remove Left Border
  removeLeftBorder: ->
    @model.set 'left_border', false
    @leftBorder = false

    @$el.removeClass 'group-left-border'

    # For each item, push in 15px (1px add for border, total of 16px)
    _.each @contentItemViewsArray, (contentItemView) ->

      if contentItemView instanceof Newstime.TextAreaView
        contentItemView.needsReflow = true

      model = contentItemView.model
      left = model.get('left')
      if left = 15
        model.set
          left: 0
          width: model.get('width') + 16

      if contentItemView instanceof Newstime.TextAreaView
        contentItemView.reflow()


  _setBoundry: (boundry)->
    current = @getBoundry()

    # Get difference
    topDelta = boundry.top - current.top
    leftDelta = boundry.left - current.left

    # Apply Difference
    _.each @contentItemViewsArray, (canvasItem) ->
      canvasItem.model.set
        top: canvasItem.model.get('top') - topDelta
        left: canvasItem.model.get('left') - leftDelta

    @model.set _.pick boundry, 'top', 'left', 'width', 'height'

  _createModel: (attrs={}) ->
    @edition.groups.add(attrs)

  _createPropertiesView: ->
    new Newstime.GroupPropertiesView(groupView: this, groupModel: @model)
