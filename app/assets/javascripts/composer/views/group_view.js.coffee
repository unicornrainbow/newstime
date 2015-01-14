class @Newstime.GroupView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'group-view'

    @propertiesView = new Newstime.GroupPropertiesView(target: this, model: @model)

    @outlineView = options.outlineView

    @composer = options.composer

    @page = options.page
    @pageView = options.pageView

    @bind
      mouseover: @mouseover
      mouseout: @mouseout
      mousedown: @mousedown
      keydown: @keydown

  render: ->
    @$el.css _.pick @model.attributes, 'width', 'height', 'top', 'left'

  measurePosition: ->
    @contentItems = @model.getContentItems()
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
      @composer.selectGroup(@model)

    # Pass mouse down to selection
    @composer.activeSelectionView.trigger 'mousedown', e

    #if @hoveredHandle
      #@trackResize @hoveredHandle.type
    #else
      #geometry = @getGeometry()
      #@trackMove(e.x - geometry.left, e.y - geometry.top)


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

    #groupedItems = @model.getContentItems()

    #_.each groupedItems, (item) ->
      #item.set('group_id', nil)

    #@model.delete()

    ## Delete the group
    ##
    ##
    ## TODO: Implement ungroup
    #console.log 'ungroup'


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

  select: (selectionView) ->
    unless @selected
      @selected = true
      @selectionView = selectionView
      #@trigger 'select',
        #contentItemView: this
        #contentItem: @model

  deselect: ->
    if @selected
      @selected = false
      @selectionView = null
      @trigger 'deselect', this


  setSizeAndPosition: (attributes) ->
    @model.set(attributes)
