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

    @$el.css top: "#{@topOffset}px"
    @$el.addClass 'canvas-view-layer'


    @contentItemCollection = @edition.get('content_items')

    # Capture all the pages & content items
    @contentItemSelector = '[data-content-item-id]'
    @pageSelector        = '[data-page-id]'

    contentItemEls     = @$(@contentItemSelector).detach()
    pageEls            = @$(@pageSelector).detach()

    @$pages = @$('[pages]')

    @pageViews = {}
    @pageContentItems = {}

    ## Add each of the pages back, rebuilding the view in the correct order.
    ## Need pages for this section, ordered by page number.
    @pages = new Backbone.Collection(section.getPages())
    @pages.each (page) =>
      page_id = page.get('_id')
      el = pageEls.filter("[data-page-id='#{page_id}']")

      view = new Newstime.PageComposeView
        el: el
        page: page # TODO: Rename to model
        edition: @edition

      @$pages.append(el)

      @pageViews[page_id] = view
      @pageContentItems[page_id] = page.getContentItems()

    @$canvasItems = $('<div class="canvas-items"></div>')
    @$canvasItems.appendTo(@$body)

    # Position canvas items div layer
    @positionCanvasItemsContainer()


    @contentItemViews = options.contentItemViews
    @contentItemOutlineViews = {}

    @pages.each (page) =>
      pageID = page.get('_id')
      pageView = @pageViews[pageID]

      # Get page offsets to pass to content items
      pageOffsetLeft = pageView.getOffsetLeft()
      pageOffsetTop  = pageView.getOffsetTop()

      contentItems = @pageContentItems[pageID]

      _.each contentItems, (contentItem) =>

        # Construct and add in each content item.
        id = contentItem.get('_id')
        el = contentItemEls.filter("[data-content-item-id='#{id}")

        contentItemType = contentItem.get('_type')

        # What is the content items type?
        contentItemViewType =
          switch contentItemType
            when 'HeadlineContentItem' then Newstime.HeadlineView
            when 'TextAreaContentItem' then Newstime.TextAreaView
            when 'PhotoContentItem' then Newstime.PhotoView
            when 'VideoContentItem' then Newstime.VideoView

        contentItemOutlineView = new Newstime.ContentItemOutlineView
          composer: @composer
          model: contentItem
          pageOffsetLeft: pageOffsetLeft
          pageOffsetTop: pageOffsetTop
        @composer.outlineLayerView.attach(contentItemOutlineView)

        contentItemView = new contentItemViewType
          model: contentItem
          el: el
          pageOffsetLeft: pageOffsetLeft
          pageOffsetTop: pageOffsetTop
          composer: @composer
          outlineView: contentItemOutlineView
          page: page
          pageID: pageID
          pageView: pageView

        contentItemView.bind 'activate', @selectContentItem, this
        contentItemView.bind 'deactivate', @selectionDeactivated, this
        contentItemView.bind 'tracking', @resizeSelection, this
        contentItemView.bind 'tracking-release', @resizeSelectionRelease, this

        contentItemCID = contentItem.cid
        @contentItemViews[contentItemCID] = contentItemView
        @contentItemOutlineViews[contentItemCID] = contentItemOutlineView
        @$canvasItems.append(el)


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

    @composer.bind 'zoom', @zoom, this

    # Create link area, to enable clicking through on links.
    @linkAreas = _.map @$el.find('a'), (link) =>
      new Newstime.LinkArea(link, topOffset: @topOffset, composer: @composer)

  extractHeadlinesViews: (el) ->
    els = $('[headline-control]', el).detach()
    _.map els, (el) =>
      id = $(el).data('content-item-id')
      model = @contentItemCollection.findWhere(_id: id)
      new Newstime.HeadlineView
        el: el
        model: model
        composer: @composer

  render: ->
    @measureLinks()

  # Measure link areas. Right now, need to do this after render to ensure we get
  # to correct values. Should be improved.
  measureLinks: =>
    _.invoke @linkAreas, 'measure'

  handlePageFocus: (page) ->
    @focusedPage = page
    @trigger 'focus', this

  # Update canvas item container to overlay pages.
  positionCanvasItemsContainer: ->
    # TODO: Move this functionality up to the composer
    @pagesOffset = @$pages.offset()
    @pagesOffset.height = @$pages.height()
    @pagesOffset.width = @$pages.width()
    @position = _.clone(@pagesOffset)


    # Dezoom
    if @zoomLevel
      @position.height = @pagesOffset.height/@zoomLevel
      @position.width = @pagesOffset.width/@zoomLevel

      @position.left -= (@position.width - @pagesOffset.width)/2

    @$canvasItems.css(@position)

    @composer.outlineLayerView.setPosition @position
    @composer.selectionLayerView.setPosition @position


  # Handler for updating view after a zoom change.
  zoom: ->
    @zoomLevel = @composer.zoomLevel

    transform = 'transform': "scale(#{@zoomLevel})"
    @$el.css(transform)
    @$canvasItems.css(transform)

    @positionCanvasItemsContainer()

  windowResize: ->
    @positionCanvasItemsContainer()

    #@canvasItemsView.setPosition(@pagesView.getPosition())
    #_.each @pages, (page) =>
      #page.trigger 'windowResize'

    #_.each @selectionViews, (item) =>
      #item.trigger 'windowResize'


  keydown: (e) ->
    if @composer.activeSelection
      @composer.activeSelection.trigger 'keydown', e

  paste: (e) ->
    if @composer.activeSelection
      @composer.activeSelection.trigger 'paste', e

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

  # Coverts external to internal coordinates.
  mapExternalCoords: (x, y) ->
    # Apply pages offset, to focus on draw surface.
    y -= @pagesOffset.top
    x -= @pagesOffset.left

    # Apply scroll offset
    x += $(window).scrollLeft()
    y += $(window).scrollTop()

    # Apply zoom
    if @zoomLevel
      x = Math.round(x/@zoomLevel)
      y = Math.round(y/@zoomLevel)

    #console.log @pagesOffset.left


    return [x, y]

  # Returns a wrapper event with external coords mapped to internal.
  # Note: Wrapping the event prevents modifying coordinates on the orginal
  # event. Stop propagation and prevent are called through to the wrapped event.
  getMappedEvent: (event) ->
    event = new Newstime.Event(event)                         # Wrap event in a newstime event object, copies coords.
    [event.x, event.y] = @mapExternalCoords(event.x, event.y) # Map coordinates
    return event                                              # Return event with mapped coords.

  mouseover: (e) ->
    @hovered = true
    e = @getMappedEvent(e)
    @pushCursor() # Replace with hover stack implementation eventually
    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

  mouseout: (e) ->
    @hovered = false
    e = @getMappedEvent(e)
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
    e = @getMappedEvent(e)

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
          @composer.clearSelection() if @composer.activeSelection
          #@drawSelection(e.x, e.y)

  mouseup: (e) ->
    e = @getMappedEvent(e)

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
    e = @getMappedEvent(e)

    if @hoveredObject
      @hoveredObject.trigger 'dblclick', e

  contextmenu: (e) ->
    e = @getMappedEvent(e)

    if @hoveredObject
      @hoveredObject.trigger 'contextmenu', e

  mousemove: (e) ->
    # Create a new event with corrdinates relative to the canvasItemsView
    e = @getMappedEvent(e)

    if @resizeSelectionTarget
      @resizeSelectionTarget.trigger 'mousemove', e
      return true

    #if @trackingSelection
      #@trackingSelection.$el.css
        #width: @snapToGridRight(e.x - @trackingSelection.anchorX)
        #height: e.y - @trackingSelection.anchorY
      #return true

    ## Check for hit inorder to highlight hovered selection
    if @composer.activeSelectionView # Check active selection first.
      selection = @composer.activeSelectionView if @composer.activeSelectionView.hit(e.x, e.y)

    unless selection
      # NOTE: Would be nice to skip active selection here, since already
      # checked, but no biggie.
      selection = _.find @contentItemViews, (contentItem, id) ->
        contentItem.hit(e.x, e.y)

    unless selection
      # NOTE: Would be nice to skip active selection here, since already
      # checked, but no biggie.
      selection = _.find @linkAreas, (linkArea) ->
        linkArea.hit(e.x, e.y)

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

  drawTypeArea: (x, y) ->
    ## We need to create and activate a selection region (Marching ants would be nice)

    # Determined which page was hit...
    pageView = _.find @pageViews, (pageView, pageID) =>
      @detectHitY pageView, y

    pageModel = pageView.page
    pageID = pageModel.get('_id')

    pageOffsetLeft = pageView.getOffsetLeft()
    pageOffsetTop  = pageView.getOffsetTop()


    contentItemType = 'TextAreaContentItem'

    contentItem = new Newstime.ContentItem
      _type: contentItemType
      page_id: pageID
    @edition.get('content_items').add(contentItem)

    contentItemOutlineView = new Newstime.ContentItemOutlineView
      composer: @composer
      model: contentItem
      pageOffsetLeft: pageOffsetLeft
      pageOffsetTop: pageOffsetTop
    @composer.outlineLayerView.attach(contentItemOutlineView)

    contentItemView = new Newstime.TextAreaView
      model: contentItem
      pageOffsetLeft: pageOffsetLeft
      pageOffsetTop: pageOffsetTop
      composer: @composer
      outlineView: contentItemOutlineView
      page: pageModel
      pageID: pageID
      pageView: pageView


    contentItemView.bind 'activate', @selectContentItem, this
    contentItemView.bind 'deactivate', @selectionDeactivated, this
    contentItemView.bind 'tracking', @resizeSelection, this
    contentItemView.bind 'tracking-release', @resizeSelectionRelease, this


    contentItemCID = contentItem.cid # TODO: Note, using cid, because not saved yet...

    @contentItemViews[contentItemCID] = contentItemView
    @contentItemOutlineViews[contentItemCID] = contentItemOutlineView
    @$canvasItems.append(contentItemView.el)

    @composer.select contentItem

    pageRelX = x - pageOffsetLeft
    pageRelY = y - pageOffsetTop

    @composer.activeSelectionView.beginDraw(pageRelX, pageRelY)

    attachContentEl = (response) =>
      $el = $(response)
      contentItemView.$el.replaceWith($el)
      contentItemView.setElement($el)

    $.ajax
      method: 'GET'
      url: "#{@edition.url()}/render_content_item.html"
      data:
        composing: true
        content_item: contentItem.toJSON()
      success: attachContentEl

  drawPhoto: (x, y) ->

    ## We need to create and activate a selection region (Marching ants would be nice)

    # Determined which page was hit...
    pageView = _.find @pageViews, (pageView, pageID) =>
      @detectHitY pageView, y

    pageModel = pageView.page
    pageID = pageModel.get('_id')

    pageOffsetLeft = pageView.getOffsetLeft()
    pageOffsetTop  = pageView.getOffsetTop()


    contentItemType = 'PhotoContentItem'

    contentItem = new Newstime.ContentItem
      _type: contentItemType
      page_id: pageID
    @edition.get('content_items').add(contentItem)

    contentItemOutlineView = new Newstime.ContentItemOutlineView
      composer: @composer
      model: contentItem
      pageOffsetLeft: pageOffsetLeft
      pageOffsetTop: pageOffsetTop
    @composer.outlineLayerView.attach(contentItemOutlineView)

    contentItemView = new Newstime.PhotoView
      model: contentItem
      pageOffsetLeft: pageOffsetLeft
      pageOffsetTop: pageOffsetTop
      composer: @composer
      outlineView: contentItemOutlineView
      page: pageModel
      pageID: pageID
      pageView: pageView


    contentItemView.bind 'activate', @selectContentItem, this
    contentItemView.bind 'deactivate', @selectionDeactivated, this
    contentItemView.bind 'tracking', @resizeSelection, this
    contentItemView.bind 'tracking-release', @resizeSelectionRelease, this


    contentItemCID = contentItem.cid # TODO: Note, using cid, because not saved yet...

    @contentItemViews[contentItemCID] = contentItemView
    @contentItemOutlineViews[contentItemCID] = contentItemOutlineView
    @$canvasItems.append(contentItemView.el)

    @composer.select contentItem

    pageRelX = x - pageOffsetLeft
    pageRelY = y - pageOffsetTop

    @composer.activeSelectionView.beginDraw(pageRelX, pageRelY)

    attachContentEl = (response) =>
      $el = $(response)
      contentItemView.$el.replaceWith($el)
      contentItemView.setElement($el)

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
    selectionView.bind 'activate', @selectContentItem, this
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


    ## We need to create and activate a selection region (Marching ants would be nice)

    # Determined which page was hit...
    pageView = _.find @pageViews, (pageView, pageID) =>
      @detectHitY pageView, y

    pageModel = pageView.page
    pageID = pageModel.get('_id')

    pageOffsetLeft = pageView.getOffsetLeft()
    pageOffsetTop  = pageView.getOffsetTop()


    contentItemType = 'HeadlineContentItem'

    contentItem = new Newstime.ContentItem
      _type: contentItemType
      page_id: pageID
    @edition.get('content_items').add(contentItem)

    contentItemOutlineView = new Newstime.ContentItemOutlineView
      composer: @composer
      model: contentItem
      pageOffsetLeft: pageOffsetLeft
      pageOffsetTop: pageOffsetTop
    @composer.outlineLayerView.attach(contentItemOutlineView)

    contentItemView = new Newstime.HeadlineView
      model: contentItem
      pageOffsetLeft: pageOffsetLeft
      pageOffsetTop: pageOffsetTop
      composer: @composer
      outlineView: contentItemOutlineView
      page: pageModel
      pageID: pageID
      pageView: pageView


    contentItemView.bind 'activate', @selectContentItem, this
    contentItemView.bind 'deactivate', @selectionDeactivated, this
    contentItemView.bind 'tracking', @resizeSelection, this
    contentItemView.bind 'tracking-release', @resizeSelectionRelease, this


    contentItemCID = contentItem.cid # TODO: Note, using cid, because not saved yet...

    @contentItemViews[contentItemCID] = contentItemView
    @contentItemOutlineViews[contentItemCID] = contentItemOutlineView
    @$canvasItems.append(contentItemView.el)

    @composer.select contentItem

    pageRelX = x - pageOffsetLeft
    pageRelY = y - pageOffsetTop

    @composer.activeSelectionView.beginDraw(pageRelX, pageRelY)

    attachContentEl = (response) =>
      $el = $(response)
      contentItemView.$el.replaceWith($el)
      contentItemView.setElement($el)

    $.ajax
      method: 'GET'
      url: "#{@edition.url()}/render_content_item.html"
      data:
        composing: true
        content_item: contentItem.toJSON()
      success: attachContentEl


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
    selectionView.bind 'activate', @selectContentItem, this
    selectionView.bind 'deactivate', @selectionDeactivated, this
    selectionView.bind 'tracking', @resizeSelection, this
    selectionView.bind 'tracking-release', @resizeSelectionRelease, this

    selectionView.beginSelection(x, y)

  selectContentItem: (e) ->

    selection = new Newstime.ContentItemSelection
      contentItem: e.contentItem
      contentItemView: e.contentItemView

    @composer.setSelection(selection)
    @trigger 'focus', this # Trigger focus event to get keyboard events

  selectionDeactivated: (selection) ->
    @composer.clearSelection()

  resizeSelection: (selection) ->
    @resizeSelectionTarget = selection
    @trigger 'tracking', this

  resizeSelectionRelease: (selection) ->
    @resizeSelectionTarget = null
    @trigger 'tracking-release', this

  append: (el) ->
    @$el.append(el)
