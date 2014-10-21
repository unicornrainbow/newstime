@Newstime = @Newstime || {}

class @Newstime.PageComposeView extends Backbone.View

  initialize: (options) ->
    @edition = options.edition
    @composer = options.composer
    @contentItemCollection = @edition.get('content_items')
    @toolbox = options.toolbox
    @$el.addClass 'page-compose'


    @composer = options.composer
    @page = options.page

    @page.bind 'destroy', @pageDestroyed, this

    @contextMenu = new Newstime.PageContextMenu
      page: @page
    @$el.append(@contextMenu.el)

    @canvasLayerView = options.canvasLayerView

    #@gridLines = new Newstime.GridLines()
    #@$el.append(@gridLines.el)

    @grid = new Newstime.GridView
    @$el.append(@grid.el)

    @bind 'mouseover',   @mouseover
    @bind 'mouseout',    @mouseout
    @bind 'mousedown',   @mousedown
    @bind 'mouseup',     @mouseup
    @bind 'mousemove',   @mousemove
    @bind 'dblclick',    @dblclick
    @bind 'keydown',     @keydown
    @bind 'contextmenu', @contextmenu

    @selectionViews = []

    # Initialize Headline Controls
    $("[headline-control]", @$el).each (i, el) =>
      id = $(el).data('content-item-id')
      contentItem = @contentItemCollection.findWhere(_id: id)

      selectionView = new Newstime.HeadlineView(model: contentItem, page: this, composer: @composer, headlineEl: el) # Needs to be local to the "page"
      @selectionViews.push selectionView
      @$el.append(selectionView.el)

      # Bind to events
      selectionView.bind 'activate', @selectionActivated, this
      selectionView.bind 'deactivate', @selectionDeactivated, this
      selectionView.bind 'tracking', @resizeSelection, this
      selectionView.bind 'tracking-release', @resizeSelectionRelease, this

    # Initilize Text Areas Controls
    $("[story-text-control]", @$el).each (i, el) =>
      id = $(el).data('content-item-id')
      contentItem = @contentItemCollection.findWhere(_id: id)

      selectionView = new Newstime.SelectionView(model: contentItem, page: this, composer: @composer) # Needs to be local to the "page"
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
    #@$el[0].getBoundingClientRect()
    Math.round(@$el.offset().left)


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
    @pushCursor() # Replace with hover stack implementation eventually
    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

  mouseout: (e) ->
    @adjustEventXY(e)
    @popCursor()

    @hovered = false

    if @hoveredObject
      @hoveredObject.trigger 'mouseout', e
      @hoveredObject = null

  getCursor: ->
    cursor = switch @toolbox.get('selectedTool')
      when 'select-tool' then 'default'
      when 'type-tool' then "-webkit-image-set(url('/assets/type_tool_cursor.png') 2x), auto"
      when 'headline-tool' then "-webkit-image-set(url('/assets/headline_tool_cursor.png') 2x), auto"

    #when 'text-tool' then 'pointer'
    #when 'text-tool' then 'text'

  pushCursor: ->
    @composer.pushCursor(@getCursor())

  popCursor: ->
    @composer.popCursor()

  # Applies offset (sort of a hack for now)
  adjustEventXY: (e) ->
    # Apply scroll offset
    e.x -= @x()
    e.y -= @y()

  mouseup: (e) ->
    @adjustEventXY(e) # Could be nice to abstract this one layer up...
    #console.log "mouseup", e

  keydown: (e) ->
    if @activeSelection
      @activeSelection.trigger 'keydown', e

  mousedown: (e) ->
    return unless e.button == 0 # Only respond to left button mousedown.

    @adjustEventXY(e) # Could be nice to abstract this one layer up...

    if @hoveredObject
      # Pass on mousedown to hovered object
      @hoveredObject.trigger 'mousedown', e
    else
      switch @toolbox.get('selectedTool')
        when 'type-tool'
          @drawTypeArea(e.x, e.y)
        when 'headline-tool'
          @drawHeadline(e.x, e.y)
          #@beginSelection(e.x, e.y)
        when 'select-tool'
          @activeSelection.deactivate() if @activeSelection


  dblclick: (e) ->
    return unless e.button == 0 # Only respond to left button mousedown.

    @adjustEventXY(e) # Could be nice to abstract this one layer up...

    if @hoveredObject
      # Pass on mousedown to hovered object
      @hoveredObject.trigger 'dblclick', e

  contextmenu: (e) ->
    e.preventDefault() # Cancel default context menu

    @adjustEventXY(e) # Could be nice to abstract this one layer up...

    @composer.displayContextMenu @contextMenu

    @contextMenu.show(e.x, e.y)

  drawTypeArea: (x, y) ->
    ## We need to create and activate a selection region (Marching ants would be nice)

    contentItem = new Newstime.ContentItem
      _type: 'StoryTextContentItem'
      page_id: @page.get('_id')

    @edition.get('content_items').add(contentItem)

    selectionView = new Newstime.SelectionView(model: contentItem, page: this, composer: @composer) # Needs to be local to the "page"
    @selectionViews.push selectionView
    @$el.append(selectionView.el)

    # Bind to events
    selectionView.bind 'activate', @selectionActivated, this
    selectionView.bind 'deactivate', @selectionDeactivated, this
    selectionView.bind 'tracking', @resizeSelection, this
    selectionView.bind 'tracking-release', @resizeSelectionRelease, this

    selectionView.beginSelection(x, y)

  drawHeadline: (x, y) ->

    # Because the content items are rendered on the backend, I need to go to the
    # backend to render the version to be displayed. In reality, the headline as
    # it stands in string interpolation, and can easily be rendered front end
    # with something like mustache. Doing it on the backend is a quirk of my
    # application design. We should be able to request the content, but draw the
    # box right away. This hoever does complicate the design, but the
    # asyncronous nature should be fine. I think I will look to fecth the inards
    # asyncronously, knowning that I don't need the content for sizing, and this
    # will leave the design intact as such.

    contentItem = new Newstime.ContentItem
      _type: 'HeadlineContentItem'
      page_id: @page.get('_id')

    @edition.get('content_items').add(contentItem)


    selectionView = new Newstime.HeadlineView(model: contentItem, page: this, composer: @composer) # Needs to be local to the "page"
    @selectionViews.push selectionView
    @$el.append(selectionView.el)


    # Bind to events
    selectionView.bind 'activate', @selectionActivated, this
    selectionView.bind 'deactivate', @selectionDeactivated, this
    selectionView.bind 'tracking', @resizeSelection, this
    selectionView.bind 'tracking-release', @resizeSelectionRelease, this

    selectionView.beginSelection(x, y)

    contentItem.save ->
      console.log "Saved"

  beginSelection: (x, y) ->
    ## We need to create and activate a selection region (Marching ants would be nice)

    contentItem = new Newstime.ContentItem
      _type: 'BoxContentItem'
      page_id: @page.get('_id')

    @edition.get('content_items').add(contentItem)

    selectionView = new Newstime.SelectionView(model: contentItem, page: this, composer: @composer) # Needs to be local to the "page"
    @selectionViews.push selectionView
    @$el.append(selectionView.el)

    # Bind to events
    selectionView.bind 'activate', @selectionActivated, this
    selectionView.bind 'deactivate', @selectionDeactivated, this
    selectionView.bind 'tracking', @resizeSelection, this
    selectionView.bind 'tracking-release', @resizeSelectionRelease, this

    selectionView.beginSelection(x, y)

  selectionActivated: (selection) ->
    @composer.setSelection(selection)
    #@activeSelection.deactivate() if @activeSelection
    @activeSelection = selection
    @trigger 'focus', this # Trigger focus event to get keyboard events

  selectionDeactivated: (selection) ->
    @composer.clearSelection()
    @activeSelection = null

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
      @hoveredObject = selection
      return true


  mouseup: (e) ->
    if @resizeSelectionTarget
      @resizeSelectionTarget.trigger 'mouseup', e
      return true

    if @trackingSelection
      @trackingSelection = null # TODO: Should still be active, just not tracking
      @trigger 'tracking-release', this


  snapLeft: (value) ->
    @grid.snapLeft(value)

  snapRight: (value) ->
    @grid.snapRight(value)

  stepLeft: (value) ->
    @grid.stepLeft(value)

  stepRight: (value) ->
    @grid.stepRight(value)

  snapTop: (value) ->
    #closest = Newstime.closest(value, @topSnapPoints)
    #if Math.abs(closest - value) < 10 then closest else value
    Math.max value, 0

  getWidth: ->
    @grid.pageWidth

  snapBottom: (value) ->
    #closest = Newstime.closest(value, @bottomSnapPoints)
    #if Math.abs(closest - value) < 10 then closest else value
    value

  pageDestroyed: ->
    # TODO: Need to properly unbind events and allow destruction of view
    @$el.remove()

  # Computes top snap points
  computeTopSnapPoints: ->
    @topSnapPoints = _.map @selectionViews, (view) ->
      view.getTop()

  computeBottomSnapPoints: ->
    @bottomSnapPoints = _.map @selectionViews, (view) ->
      view.getTop() + view.getHeight()
