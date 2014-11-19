class @Newstime.CanvasLayerView extends Backbone.View

  initialize: (options) ->
    @composer = options.composer
    @topOffset = options.topOffset
    @edition = options.edition
    @toolbox = options.toolbox

    # Capture Elements
    @$window = $(window)
    @$document = $(document)
    @$body = $('body')
    @$grid = @$('.grid') # Where to append pages to (HACK)

    @$el.css top: "#{@topOffset}px"
    @$el.addClass 'canvas-view-layer'

    # Ensure nothing can be highlighted with a user drag (Which breaks the
    # solidness of the ui)
    @$el.css "-webkit-user-select": "none"

    @zoomLevels = [25, 33, 50, 67, 75, 90, 100, 110, 125, 150, 175, 200, 250, 300, 400, 500]
    @zoomLevelIndex = 6
    #@zoomLevels = [100, 110, 125, 150, 175, 200, 250, 300, 400, 500]

    ### Pages
    #########

    @pageCollection = @edition.get('pages')

    # Capture and Init pages
    @pages = []
    $("[page-compose]", @$el).each (i, el) =>
      pageModel = @pageCollection.findWhere(_id: $(el).data('page-id'))
      pageView = new Newstime.PageComposeView
        el: el
        page: pageModel
        edition: @edition
        canvasLayerView: this
        composer: @composer
        toolbox: @toolbox

      @pages.push pageView

    _.each @pages, (page) =>
      page.bind 'tracking', @tracking, this
      page.bind 'focus', @handlePageFocus, this
      page.bind 'tracking-release', @trackingRelease, this


    # Add an add page button
    @addPageButton = new Newstime.AddPageButton
      composer: @composer

    @$el.append(@addPageButton.el)

    ### ItemViews
    #############

    @contentItemCollection = @edition.get('content_items')
    @selectionViews = []

    # For each page, extract and place the content items onto the canvas view
    # layer in association with the page.

    _.each @pages, (page) =>

      $("[headline-control]", page.$el).each (i, el) =>
        id = $(el).data('content-item-id')
        contentItem = @contentItemCollection.findWhere(_id: id)

        selectionView = new Newstime.HeadlineView(model: contentItem, page: page, composer: @composer, headlineEl: el) # Needs to be local to the "page"
        @selectionViews.push selectionView
        @$el.append(el) # Move element from page to canvas layer
        @$el.append(selectionView.el)

        # Bind to events
        selectionView.bind 'activate', @selectionActivated, this
        selectionView.bind 'deactivate', @selectionDeactivated, this
        selectionView.bind 'tracking', @resizeSelection, this
        selectionView.bind 'tracking-release', @resizeSelectionRelease, this

      # Initilize Text Areas Controls
      $("[text-area-control]", page.$el).each (i, el) =>
        id = $(el).data('content-item-id')
        contentItem = @contentItemCollection.findWhere(_id: id)

        selectionView = new Newstime.TextAreaView(model: contentItem, page: page, composer: @composer, contentEl: el) # Needs to be local to the "page"
        @selectionViews.push selectionView
        @$el.append(el) # Move element from page to canvas layer
        @$el.append(selectionView.el)

        # Bind to events
        selectionView.bind 'activate', @selectionActivated, this
        selectionView.bind 'deactivate', @selectionDeactivated, this
        selectionView.bind 'tracking', @resizeSelection, this
        selectionView.bind 'tracking-release', @resizeSelectionRelease, this

      # Initilize Text Areas Controls
      $("[photo-control]", page.$el).each (i, el) =>
        id = $(el).data('content-item-id')
        contentItem = @contentItemCollection.findWhere(_id: id)

        selectionView = new Newstime.PhotoView(model: contentItem, page: page, composer: @composer, contentEl: el) # Needs to be local to the "page"
        @selectionViews.push selectionView
        @$el.append(el) # Move element from page to canvas layer
        @$el.append(selectionView.el)


        # Bind to events
        selectionView.bind 'activate', @selectionActivated, this
        selectionView.bind 'deactivate', @selectionDeactivated, this
        selectionView.bind 'tracking', @resizeSelection, this
        selectionView.bind 'tracking-release', @resizeSelectionRelease, this

      # Initilize Text Areas Controls
      $("[video-control]", page.$el).each (i, el) =>
        id = $(el).data('content-item-id')
        contentItem = @contentItemCollection.findWhere(_id: id)

        selectionView = new Newstime.VideoView(model: contentItem, page: page, composer: @composer, contentEl: el) # Needs to be local to the "page"
        @selectionViews.push selectionView
        @$el.append(el) # Move element from page to canvas layer
        @$el.append(selectionView.el)

        # Bind to events
        selectionView.bind 'activate', @selectionActivated, this
        selectionView.bind 'deactivate', @selectionDeactivated, this
        selectionView.bind 'tracking', @resizeSelection, this
        selectionView.bind 'tracking-release', @resizeSelectionRelease, this


    # Bind mouse events
    @bind 'mouseover',  @mouseover
    @bind 'mouseout',   @mouseout
    @bind 'mousedown',  @mousedown
    @bind 'mouseup',    @mouseup
    @bind 'mousemove',  @mousemove
    @bind 'dblclick',   @dblclick
    @bind 'keydown',    @keydown
    @bind 'paste',      @paste
    @bind 'contextmenu', @contextmenu
    @bind 'windowResize', @windowResize

  handlePageFocus: (page) ->
    @focusedPage = page
    @trigger 'focus', this

  windowResize: ->
    _.each @pages, (page) =>
      page.trigger 'windowResize'

    _.each @selectionViews, (item) =>
      item.trigger 'windowResize'

  #keydown: (e) ->
    #if @focusedPage
      #@focusedPage.trigger 'keydown', e

  keydown: (e) ->
    if @activeSelection
      @activeSelection.trigger 'keydown', e

  paste: (e) ->
    if @focusedPage
      @focusedPage.trigger 'paste', e

  addPage: (pageModel) ->
    pageModel.getHTML (html) =>
      el = $(html)[0]
      @$grid.append(el)

      pageView = new Newstime.PageComposeView(
        el: el
        page: pageModel
        edition: @edition
        canvasLayerView: this
        composer: @composer
        toolbox: @toolbox
      )
      @pages.push pageView

      pageView.bind 'tracking', @tracking, this
      pageView.bind 'tracking-release', @trackingRelease, this



  tracking: (page) ->
    @trackingPage = page
    @trigger 'tracking', this

  trackingRelease: (page) ->
    @trackingPage = null
    @trigger 'tracking-release', this

  hit: (x, y) ->
    return true # Since canvas is the bottom-most layer, we assume everything hits it if asked.


  # Calibrates xy to the canvas layer.
  adjustEventXY: (e) ->
    # Apply scroll offset
    e.x += $(window).scrollLeft()
    e.y += $(window).scrollTop()

    # Apply zoom
    if @zoomLevel
      e.x = Math.round(e.x/@zoomLevel)
      e.y = Math.round(e.y/@zoomLevel)

  mouseover: (e) ->
    @hovered = true
    @adjustEventXY(e)
    @pushCursor() # Replace with hover stack implementation eventually
    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

  mouseout: (e) ->
    @hovered = false
    @adjustEventXY(e)
    @popCursor()
    if @hoveredObject
      @hoveredObject.trigger 'mouseout', e
      @hoveredObject = null

  getCursor: ->
    cursor = switch @toolbox.get('selectedTool')
      when 'select-tool' then 'default'
      when 'type-tool' then "-webkit-image-set(url('/assets/type_tool_cursor.png') 2x), auto"
      when 'headline-tool' then "-webkit-image-set(url('/assets/headline_tool_cursor.png') 2x), auto"
      when 'photo-tool' then "-webkit-image-set(url('/assets/photo_tool_cursor.png') 2x), auto"
      when 'video-tool' then "-webkit-image-set(url('/assets/video_tool_cursor.png') 2x), auto"

    #when 'text-tool' then 'pointer'
    #when 'text-tool' then 'text'

  pushCursor: ->
    @composer.pushCursor(@getCursor())

  popCursor: ->
    @composer.popCursor()

  mousedown: (e) ->
    @adjustEventXY(e)

    if @hoveredObject
      @hoveredObject.trigger 'mousedown', e
    else
      switch @toolbox.get('selectedTool')
        when 'type-tool'
          @drawTypeArea(e.x, e.y)
        when 'headline-tool'
          @drawHeadline(e.x, e.y)
        when 'photo-tool'
          @drawPhoto(e.x, e.y)
        when 'video-tool'
          @drawVideo(e.x, e.y)
        when 'select-tool'
          @activeSelection.deactivate() if @activeSelection
          @drawSelection(e.x, e.y)

  mouseup: (e) ->
    @adjustEventXY(e)

    if @resizeSelectionTarget
      @resizeSelectionTarget.trigger 'mouseup', e
      return true

    if @trackingSelection
      @trackingSelection = null # TODO: Should still be active, just not tracking
      @trigger 'tracking-release', this

    #if @trackingPage
      #@trackingPage.trigger 'mouseup', e
      #return true

  dblclick: (e) ->
    @adjustEventXY(e)

    if @hoveredObject
      @hoveredObject.trigger 'dblclick', e

  contextmenu: (e) ->
    @adjustEventXY(e)

    if @hoveredObject
      @hoveredObject.trigger 'contextmenu', e


  mousemove: (e) ->
    @adjustEventXY(e)

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

    if selection
      if @hoveredObject != selection
        if @hoveredObject
          @hoveredObject.trigger 'mouseout', e
        @hoveredObject = selection
        @hoveredObject.trigger 'mouseover', e
    else
      if @hoveredObject
        @hoveredObject.trigger 'mouseout', e
        @hoveredObject = null

    if @hoveredObject
      @hoveredObject.trigger 'mousemove', e


    # Old mousemove code for pages
    #if @trackingPage
      #@trackingPage.trigger 'mousemove', e
      #return true

    #page = _.find @pages, (page) =>
      #@detectHit page, e.x, e.y

    ## TODO: page here is misnomber, should realy just be a local hovered object
    #unless page # If no page, check for button hit
      #if @detectHit @addPageButton, e.x, e.y
        #page = @addPageButton

    #if page
      #if @hoveredObject != page
        #if @hoveredObject
          #@hoveredObject.trigger 'mouseout', e
        #@hoveredObject = page
        #@hoveredObject.trigger 'mouseover', e

    #else
      #if @hoveredObject
        #@hoveredObject.trigger 'mouseout', e
        #@hoveredObject = null

    #if @hoveredObject
      #@hoveredObject.trigger 'mousemove', e


  detectHit: (page, x, y) ->

    # TODO: Need to refactor this to avoid to much recaluculating.

    geometry = page.geometry()

    # The x value that comes back needs to have this xCorrection value applied
    # to it to make it right. Seems to be due to a bug in jQuery that has to do
    # with the zoom property. This works for now to get the correct offset
    # value.
    if @zoomLevel
      xCorrection = Math.round(($(window).scrollLeft()/@zoomLevel) * (@zoomLevel - 1))
    else
      xCorrection = 0

    geometry.x -= xCorrection


    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 4 # 2px
    geometry.x -= buffer
    geometry.y -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    #console.log x, y
    #console.log geometry

    ## Detect if corrds lie within the geometry
    if x >= geometry.x && x <= geometry.x + geometry.width
      if y >= geometry.y && y <= geometry.y + geometry.height
        return true

    return false


  detectHitY: (page, y) ->
    geometry = page.geometry()

    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 4 # 2px
    geometry.y -= buffer
    geometry.height += buffer*2

    ## Detect if corrds lie within the geometry
    if y >= geometry.y && y <= geometry.y + geometry.height
      return true

    return false


  ## Zoom stuff below for the moment

  captureScrollPosition: (e) =>

    # If calibrated, recalulate scroll poisiton
    documentWidth = document.body.scrollWidth # scroll width give the correct width, considering auto margins on resize, versus document width
    windowWidth   = $(window).width()
    @scrollLeft   = $(window).scrollLeft()

    if documentWidth - windowWidth > 0
      @horizontalScrollPosition = Math.round(100 * @scrollLeft / (documentWidth - windowWidth))
    else
      @horizontalScrollPosition = 50


    documentHeight = document.body.scrollHeight
    windowHeight  = $(window).height()
    @scrollTop   = $(window).scrollTop()

    if documentHeight - windowHeight > 0
      @verticalScrollPosition = Math.round(100 * @scrollTop / (documentHeight - windowHeight))
    else
      @verticalScrollPosition = 50

  zoomIn: ->
    # This is a demo implementation, just to test the idea
    @zoomLevelIndex ?= 0
    @zoomLevelIndex = Math.min(@zoomLevelIndex+1, 10)
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100

    # And apply zoom level to the zoom target (page)
    #@$el.css
      #zoom: "#{@zoomLevel * 100}%"

    @$el.css
      'transform': "scale(#{@zoomLevel})"

    @repositionScroll()


  zoomInPoint: (x, y) ->
    # This is a demo implementation, just to test the idea
    @zoomLevelIndex ?= 0
    @zoomLevelIndex = Math.min(@zoomLevelIndex+1, 10)
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100

    # And apply zoom level to the zoom target (page)
    #@$el.css
      #zoom: "#{@zoomLevel * 100}%"

    @$el.css
      'transform': "scale(#{@zoomLevel})"

    # Lock scroll horizontally
    #documentWidth = document.body.scrollWidth # scroll width give the correct width, considering auto margins on resize, versus document width
    documentWidth = $(document).width() # scroll width give the correct width, considering auto margins on resize, versus document width
    windowWidth   = $(window).width()
    @scrollLeft   = $(window).scrollLeft()


    if documentWidth - windowWidth == 0
      # Assumed scroll position with no scroll is 50%
      @horizontalScrollPosition = 50
    else
      # Apply scroll position
      #scrollLeft = (documentWidth - windowWidth) * (@horizontalScrollPosition/100)
      @scrollLeft = (documentWidth - windowWidth) * x/windowWidth


      $(window).scrollLeft(@scrollLeft)

    # Lock scroll vertically

    documentHeight = Math.round(document.body.scrollHeight)
    windowHeight   = Math.round($(window).height())
    @scrollTop   = Math.round($(window).scrollTop())

    if documentHeight - windowHeight == 0
      # Assumed scroll position with no scroll is 50%
      @verticalScrollPosition = 50
    else
      # Apply scroll position
      #scrollTop = (documentHeight - windowHeight) * (@verticalScrollPosition/100)
      # Need to compensate for menu bar up top...
      #scrollTop = (documentHeight - windowHeight) * y/windowHeight
      #$(window).scrollTop(scrollTop)

  zoomOut: ->

    # This is a demo implementation, just to test the idea
    @zoomLevelIndex ?= 0
    @zoomLevelIndex = Math.max(@zoomLevelIndex-1, 0)
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100

    # And apply zoom level to the zoom target (page)
    #@$el.css
      #zoom: "#{@zoomLevel * 100}%"

    @$el.css
      'transform': "scale(#{@zoomLevel})"


    @repositionScroll()

  zoomReset: ->
    @zoomLevelIndex = 6
    #@zoomLevelIndex = 0
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100

    # And apply zoom level to the zoom target (page)
    #@$el.css
      #zoom: "#{@zoomLevel * 100}%"


    @$el.css
      'transform': "scale(#{@zoomLevel})"

    @repositionScroll()

  zoomToPoint: (x, y) ->
    # This is a demo implementation, just to test the idea

    @zoomLevelIndex ?= 0
    @zoomLevelIndex = @zoomLevelIndex+1
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100
    #console.log "zooming here"

    # And apply zoom level to the zoom target (page)
    #@$el.css
      #zoom: "#{@zoomLevel * 100}%"

    @$el.css
      'transform': "scale(#{@zoomLevel})"


  repositionScroll: ->

    # Lock scroll horizontally
    #documentWidth = document.body.scrollWidth # scroll width give the correct width, considering auto margins on resize, versus document width
    documentWidth = @$document.width() # scroll width give the correct width, considering auto margins on resize, versus document width
    windowWidth   = @$window.width()
    @scrollLeft   = @$window.scrollLeft()

    if documentWidth - windowWidth == 0
      # Assumed scroll position with no scroll is 50%
      @horizontalScrollPosition = 50
    else
      # Apply scroll position
      @scrollLeft = (documentWidth - windowWidth) * (@horizontalScrollPosition/100)
      @$window.scrollLeft(@scrollLeft)

    # Lock scroll vertically

    documentHeight = Math.round(document.body.scrollHeight)
    windowHeight   = Math.round($(window).height())
    @scrollTop   = Math.round($(window).scrollTop())

    if documentHeight - windowHeight == 0
      # Assumed scroll position with no scroll is 50%
      @verticalScrollPosition = 50
    else
      # Apply scroll position
      @scrollTop = (documentHeight - windowHeight) * (@verticalScrollPosition/100)
      $(window).scrollTop(@scrollTop)


  drawTypeArea: (x, y) ->
    ## We need to create and activate a selection region (Marching ants would be nice)

    contentItem = new Newstime.ContentItem
      _type: 'TextAreaContentItem'
      page_id: @page.get('_id')

    @edition.get('content_items').add(contentItem)

    selectionView = new Newstime.TextAreaView(model: contentItem, page: this, composer: @composer) # Needs to be local to the "page"
    @selectionViews.push selectionView
    @$el.append(selectionView.el)

    # Bind to events
    selectionView.bind 'activate', @selectionActivated, this
    selectionView.bind 'deactivate', @selectionDeactivated, this
    selectionView.bind 'tracking', @resizeSelection, this
    selectionView.bind 'tracking-release', @resizeSelectionRelease, this

    selectionView.beginSelection(x, y)

    attachContentEl = (response) =>
      $contentEl = $(response)
      $contentEl.insertBefore(selectionView.$el)
      selectionView.setContentEl($contentEl)

    $.ajax
      method: 'GET'
      url: "#{@edition.url()}/render_content_item.html"
      data:
        composing: true
        content_item: contentItem.toJSON()
      success: attachContentEl

  drawPhoto: (x, y) ->

    contentItem = new Newstime.ContentItem
      _type: 'PhotoContentItem'
      page_id: @page.get('_id')

    @edition.get('content_items').add(contentItem)

    # Get the headline templte, and inject it.
    #headlineEl = @edition.getHeadlineElTemplate()
    #headlineEl: el

    selectionView = new Newstime.PhotoView(model: contentItem, page: this, composer: @composer) # Needs to be local to the "page"
    @selectionViews.push selectionView
    @$el.append(selectionView.el)

    # Bind to events
    selectionView.bind 'activate', @selectionActivated, this
    selectionView.bind 'deactivate', @selectionDeactivated, this
    selectionView.bind 'tracking', @resizeSelection, this
    selectionView.bind 'tracking-release', @resizeSelectionRelease, this

    selectionView.beginSelection(x, y)


    attachContentEl = (response) =>
      $contentEl = $(response)
      $contentEl.insertBefore(selectionView.$el)
      selectionView.setContentEl($contentEl)

    $.ajax
      method: 'GET'
      url: "#{@edition.url()}/render_content_item.html"
      data:
        composing: true
        content_item: contentItem.toJSON()
      success: attachContentEl

  drawVideo: (x, y) ->

    contentItem = new Newstime.ContentItem
      _type: 'VideoContentItem'
      page_id: @page.get('_id')

    @edition.get('content_items').add(contentItem)

    # Get the headline templte, and inject it.
    #headlineEl = @edition.getHeadlineElTemplate()
    #headlineEl: el

    selectionView = new Newstime.VideoView(model: contentItem, page: this, composer: @composer) # Needs to be local to the "page"
    @selectionViews.push selectionView
    @$el.append(selectionView.el)

    # Bind to events
    selectionView.bind 'activate', @selectionActivated, this
    selectionView.bind 'deactivate', @selectionDeactivated, this
    selectionView.bind 'tracking', @resizeSelection, this
    selectionView.bind 'tracking-release', @resizeSelectionRelease, this

    selectionView.beginSelection(x, y)

    #attachHeadlineEl = (response) =>
      #$headlineEl = $(response)
      #$headlineEl.insertBefore(selectionView.$el)
      #selectionView.setHeadlineEl($headlineEl)

    #console.log "#{@edition.url()}/render_content_item.html"

    #$.ajax
      #method: 'GET'
      #url: "#{@edition.url()}/render_content_item.html"
      #data:
        #composing: true
        #content_item: contentItem.toJSON()
      #success: attachHeadlineEl

  drawSelection: (x, y) ->
    selectionView = new Newstime.Selection()
    @$el.append(selectionView.el)

    selectionView.bind 'tracking', @resizeSelection, this
    selectionView.bind 'tracking-release', @resizeSelectionRelease, this

    selectionView.beginSelection(x, y)

  drawHeadline: (x, y) ->

    # Determined which page was hit...
    pageView = _.find @pages, (page) =>
      @detectHitY page, y

    pageModel = pageView.page

    contentItem = new Newstime.ContentItem
      _type: 'HeadlineContentItem'
      page_id: pageModel.get('_id')

    @edition.get('content_items').add(contentItem)

    # Get the headline templte, and inject it.
    #headlineEl = @edition.getHeadlineElTemplate()
    #headlineEl: el

    selectionView = new Newstime.HeadlineView(model: contentItem, page: pageView, composer: @composer) # Needs to be local to the "page"
    @selectionViews.push selectionView
    @$el.append(selectionView.el)

    # Bind to events
    selectionView.bind 'activate', @selectionActivated, this
    selectionView.bind 'deactivate', @selectionDeactivated, this
    selectionView.bind 'tracking', @resizeSelection, this
    selectionView.bind 'tracking-release', @resizeSelectionRelease, this

    selectionView.beginSelection(x, y)

    attachHeadlineEl = (response) =>
      $headlineEl = $(response)
      $headlineEl.insertBefore(selectionView.$el)
      selectionView.setHeadlineEl($headlineEl)

    console.log "#{@edition.url()}/render_content_item.html"

    $.ajax
      method: 'GET'
      url: "#{@edition.url()}/render_content_item.html"
      data:
        composing: true
        content_item: contentItem.toJSON()
      success: attachHeadlineEl

    #contentItem.save {},
      #success: (model) ->
        #$.ajax
          #url: "#{model.url()}.html"
          #data:
            #composing: true
          #success: attachHeadlineEl
        # Append and set headline el.
        #
        #selectionView.setHeadlineEl

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

  append: (el) ->
    @$el.append(el)
