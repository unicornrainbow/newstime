#= require ../views/canvas_item_view

class @Newstime.GroupView extends @Newstime.CanvasItemView

  initialize: (options={}) ->
    @$el.addClass 'group-view'

    @composer = options.composer || Newstime.composer
    @edition  = @composer.edition

    @model ?= @edition.groups.add({})

    @contentItemViewsArray = [] # Array of content items views in z-index order.

    @propertiesView = new Newstime.GroupPropertiesView(target: this, model: @model)

    @outlineView = @composer.outlineViewCollection.add
                     model: @model

    @listenTo @model, 'destroy', @remove
    @listenTo @model, 'change', @render

    @bindUIEvents()

  render: ->
    @$el.css @model.pick 'width', 'height', 'top', 'left'

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

  getPropertiesView: ->
    @propertiesView

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

  keydown: (e) =>
    switch e.keyCode
      when 85 # u
        @ungroup() if e.altKey
      when 27 # ESC
        @deselect()

  ungroup: ->
    # Remove each of the models from the group
    groupedItems = @model.getContentItems()

    _.each groupedItems, (item) ->
      item.set('group_id', null)

    @model.destroy()

  getGeometry: ->
    @model.pick('top', 'left', 'height', 'width')

  mouseover: (e) ->
    @hovered = true
    @outlineView.show()
    @composer.pushCursor @getCursor()

  getCursor: ->
    'default'

  mouseout: (e) ->

    if @hoveredHandle
      @hoveredHandle.trigger 'mouseout', e
      @hoveredHandle = null

    @hovered = false
    @outlineView.hide()
    @composer.popCursor()

  getBoundry: ->
    @model.getBoundry()

  push: (view) ->
    viewBoundry = view.model.getBoundry()

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

      @model.set _.pick newBoundry, 'top', 'left', 'width', 'height'

      # Subtract group offset from element offset.
      view.model.set
        top: viewBoundry.top - newBoundry.top
        left: viewBoundry.left - newBoundry.left


    @contentItemViewsArray.push(view)
    @$el.append(view.el)

    @model.addItem(view.model)
