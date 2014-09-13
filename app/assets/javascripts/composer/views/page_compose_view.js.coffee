@Newstime = @Newstime || {}

class @Newstime.PageComposeView extends Backbone.View

  initialize: (options) ->
    @edition = options.edition
    @contentItemCollection = @edition.get('content_items')
    @$el.addClass 'page-compose'

    @composer = options.composer
    @page = options.page

    @canvasLayerView = options.canvasLayerView

    #@gridLines = new Newstime.GridLines()
    #@$el.append(@gridLines.el)

    # Configure Grid
    @gridInit()

    @bind 'mouseover',   @mouseover
    @bind 'mouseout',    @mouseout
    @bind 'mousedown',   @mousedown
    @bind 'mouseup',     @mouseup
    @bind 'mousemove',   @mousemove

    @selectionViews = []

    # Initialize content items from page
    $("[data-content-item-id]", @$el).each (i, el) =>
      id = $(el).data('content-item-id')
      contentItem = @contentItemCollection.findWhere(_id: id)

      selectionView = new Newstime.SelectionView(model: contentItem, page: this) # Needs to be local to the "page"
      @selectionViews.push selectionView
      @$el.append(selectionView.el)

      # Bind to events
      selectionView.bind 'activate', @selectionActivated, this
      selectionView.bind 'deactivate', @selectionDeactivated, this
      selectionView.bind 'tracking', @resizeSelection, this
      selectionView.bind 'tracking-release', @resizeSelectionRelease, this

  # Sets up and compute grid steps
  gridInit: ->
    ## TODO: Get the offset to be on the grid steps
    columnWidth = 34
    gutterWidth = 16
    columns = 24

    ## Compute Left Steps
    firstStep = gutterWidth/2
    columnStep = columnWidth + gutterWidth
    @leftSteps = _(columns).times (i) ->
      columnStep * i + firstStep

    firstStep = columnWidth
    columnStep = columnWidth + gutterWidth
    @rightSteps = _(columns).times (i) ->
      columnStep * i + firstStep

  width: ->
    parseInt(@$el.css('width'))

  height: ->
    parseInt(@$el.css('height'))

  x: ->
    #parseInt(@$el.css('left'))
    #@$el[0].offsetLeft
    #Math.round(@$el.position().left)
    #Math.round(
    Math.round(@$el.offset().left)
    #@$el[0].getBoundingClientRect()


  y: ->
    parseInt(@$el.css('top'))
    @$el[0].offsetTop


  geometry: ->
    x: @x()
    y: @y()
    width: @width()
    height: @height()

  mouseover: (e) ->
    @adjustEventXY(e)
    @hovered = true
    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

  mouseout: (e) ->
    @adjustEventXY(e)

    @hovered = false

    if @hoveredObject
      @hoveredObject.trigger 'mouseout', e
      @hoveredObject = null

  # Applies offset (sort of a hack for now)
  adjustEventXY: (e) ->
    # Apply scroll offset
    e.x -= @x()
    e.y -= @y()

  mouseup: (e) ->
    @adjustEventXY(e) # Could be nice to abstract this one layer up...
    #console.log "mouseup", e

  mousedown: (e) ->
    @adjustEventXY(e) # Could be nice to abstract this one layer up...

    if @hoveredObject
      # Pass on mousedown to hovered object
      @hoveredObject.trigger 'mousedown', e
    else
      # Or begin new selection
      @beginSelection(e.x, e.y)

  beginSelection: (x, y) ->
    ## We need to create and activate a selection region (Marching ants would be nice)

    contentItem = new Newstime.ContentItem
      _type: 'BoxContentItem'
      page_id: @page.get('_id')

    @edition.get('content_items').add(contentItem)

    selectionView = new Newstime.SelectionView(model: contentItem, page: this) # Needs to be local to the "page"
    @selectionViews.push selectionView
    @$el.append(selectionView.el)

    # Bind to events
    selectionView.bind 'activate', @selectionActivated, this
    selectionView.bind 'deactivate', @selectionDeactivated, this
    selectionView.bind 'tracking', @resizeSelection, this
    selectionView.bind 'tracking-release', @resizeSelectionRelease, this

    selectionView.beginSelection(x, y)

  selectionActivated: (selection) ->
    @activeSelection.deactivate() if @activeSelection
    @activeSelection = selection

  selectionDeactivated: (selection) ->
    @activeSelection = null

  # Utility function
  closest: (goal, ary) ->
    closest = null
    $.each ary, (i, val) ->
      if closest == null || Math.abs(val - goal) < Math.abs(closest - goal)
        closest = val
    closest

  snapToGridLeft: (value) ->
    @closest(value , @leftSteps)

  snapToGridRight: (value) ->
    @closest(value , @rightSteps)

  resizeSelection: (selection) ->
    @resizeSelectionTarget = selection
    @trigger 'tracking', this

  resizeSelectionRelease: (selection) ->
    @resizeSelectionTarget = null
    @trigger 'tracking-release', this

  mousemove: (e) ->
    @adjustEventXY(e) # Could be nice to abstract this one layer up...

    if @resizeSelectionTarget
      @resizeSelectionTarget.trigger 'mousemove', e
      return true

    # Need to abstract and move this down into the selection. Kludgy for now.
    if @trackingSelection
      @trackingSelection.$el.css
        width: @snapToGridRight(e.x - @trackingSelection.anchorX)
        height: e.y - @trackingSelection.anchorY
      return true

    # Check for hit inorder to highlight hovered selection
    if @activeSelection # Check active selection first.
      selection = @activeSelection if @activeSelection.hit(e.x, e.y)

    unless selection
      # NOTE: Would be nice to skip active selection here, since already
      # checked, but no biggie.
      selection = _.find @selectionViews, (selection) ->
        selection.hit(e.x, e.y)

    if @hovered # Only process events if hovered.
      if selection
        if @hoveredObject != selection
          if @hoveredObject
            @hoveredObject.trigger 'mouseout', e
          @hoveredObject = selection
          @hoveredObject.trigger 'mouseover', e

        return true
      else
        if @hoveredObject
          @hoveredObject.trigger 'mouseout', e
          @hoveredObject = null

        return false

    else
      # Defer processing of events until we are declared the hovered object.
      @hoveredObject = page
      return true


  mouseup: (e) ->
    if @resizeSelectionTarget
      @resizeSelectionTarget.trigger 'mouseup', e
      return true

    if @trackingSelection
      @trackingSelection = null # TODO: Should still be active, just not tracking
      @trigger 'tracking-release', this


  snapLeft: (value) ->
    @closest(value , @leftSteps)

  snapRight: (value) ->
    @closest(value , @rightSteps)

  snapTop: (value) ->
    @closest(value , @topSteps)

  snapBottom: (value) ->
    @closest(value , @bottomSteps)
