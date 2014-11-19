@Newstime = @Newstime || {}

class @Newstime.PageComposeView extends Backbone.View

  initialize: (options) ->
    @edition = options.edition
    @composer = options.composer
    @canvasLayerView = options.canvasLayerView
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

    @pageBorder = new Newstime.PageBorder(page: this)
    @canvasLayerView.append(@pageBorder.el)

    @setPageBorderDimensions()

    @grid = new Newstime.GridView
    @$el.append(@grid.el)

    #@bind 'mousemove',   @mousemove
    #@bind 'mouseover',   @mouseover
    #@bind 'mouseout',    @mouseout
    #@bind 'mousedown',   @mousedown
    #@bind 'mouseup',     @mouseup
    @bind 'dblclick',    @dblclick
    @bind 'keydown',     @keydown
    @bind 'paste',       @paste
    @bind 'contextmenu', @contextmenu
    @bind 'windowResize', @windowResize # Fired when window is resized

  windowResize: ->
    @setPageBorderDimensions()


  setPageBorderDimensions: ->
    # The page border needs to no the x and y location of the page. It also
    # needs to know the page width and height, and finally it needs to know the
    # margins for each of the four sides, from this is can compute it's top,
    # left, right and bottom dimensions for rendering relative to the canvas
    # view layer.
    geometry = @geometry()
    @pageBorder.model.set
      pageX: geometry.x
      pageY: geometry.y
      pageWidth:  geometry.width
      pageHeight: geometry.height
      pageTopMargin: 190 # TODO: These values need to be set and read from the page model.
      pageLeftMargin: 8
      pageRightMargin: 8
      pageBottomMargin: 4


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


  # Applies offset (sort of a hack for now)
  adjustEventXY: (e) ->
    # Apply scroll offset
    e.x -= @x()
    e.y -= @y()


  ## Event Handlers

  paste: (e) ->
    if @activeSelection
      @activeSelection.trigger 'paste', e


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

  #keydown: (e) ->
    #if @activeSelection
      #@activeSelection.trigger 'keydown', e

  #mousemove: (e) ->
    ##@adjustEventXY(e) # Could be nice to abstract this one layer up...

  #mouseover: (e) ->
    #@adjustEventXY(e)
    ##@hovered = true
    ##if @hoveredObject
      ##@hoveredObject.trigger 'mouseover', e

  #mouseout: (e) ->
    #@adjustEventXY(e)
    #@hovered = false

    #if @hoveredObject
      #@hoveredObject.trigger 'mouseout', e
      #@hoveredObject = null

  #mousedown: (e) ->
    #return unless e.button == 0 # Only respond to left button mousedown.

    #@adjustEventXY(e) # Could be nice to abstract this one layer up...

    #if @hoveredObject
      ## Pass on mousedown to hovered object
      #@hoveredObject.trigger 'mousedown', e
    #else
      #switch @toolbox.get('selectedTool')
        #when 'type-tool'
          #@drawTypeArea(e.x, e.y)
        #when 'headline-tool'
          #@drawHeadline(e.x, e.y)
        #when 'photo-tool'
          #@drawPhoto(e.x, e.y)
        #when 'video-tool'
          #@drawVideo(e.x, e.y)
        #when 'select-tool'
          #@activeSelection.deactivate() if @activeSelection
          ##@beginSelection(e.x, e.y)

  #mouseup: (e) ->
    #@adjustEventXY(e) # Could be nice to abstract this one layer up...

    #if @resizeSelectionTarget
      #@resizeSelectionTarget.trigger 'mouseup', e
      #return true

    #if @trackingSelection
      #@trackingSelection = null # TODO: Should still be active, just not tracking
      #@trigger 'tracking-release', this

  snapLeft: (value) ->
    snapTolerance  = 20
    # Get snap values
    #gridSnap = @grid.snapLeft(value)
    pageLeftEdge = @pageBorder.model.get('pageLeftMargin')
    canvasItemSnap = Newstime.closest(value, @pageContentItemLeftEdges)

    # Find closest of snaps
    snapTo = Newstime.closest(value , [pageLeftEdge, canvasItemSnap])

    # Only use snap if snap is within tolerance
    if Math.abs(snapTo - value) < snapTolerance
      snapTo
    else
      null

  snapRight: (value) ->
    @grid.snapRight(value)
    #value

  stepLeft: (value) ->
    @grid.stepLeft(value)
    #value

  stepRight: (value) ->
    @grid.stepRight(value)
    #value

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


  # Collects left edges of canvas items on page
  #
  # If item passed as exclude, it will be excluded
  collectLeftEdges: (exclude=null) ->
    items = @page.getContentItems()
    if exclude
      items = _.reject items, (item) -> item.get('_id') == exclude.get('_id')
    @pageContentItemLeftEdges = _.map(items, (item) -> item.get('left'))


  # Collects right edges of canvas items on page
  #
  # If item passed as exclude, it will be excluded
  collectRightEdges: (exclude=null) ->
    items = @page.getContentItems()
    if exclude
      items = _.reject items, (item) -> item.get('_id') == exclude.get('_id')
    @pageContentItemRightEdges = _.map(items, (item) -> item.get('left') + item.get('width'))
