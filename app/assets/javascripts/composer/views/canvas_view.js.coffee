class @Newstime.CanvasView extends @Newstime.View

  initialize: (options) ->
    @composer = Newstime.composer
    @topOffset = options.topOffset
    @edition = options.edition
    @toolbox = options.toolbox


    # Capture Elements
    @$window = $(window)
    @$document = $(document)
    @$body = $('body')

    @$el.css top: "#{@topOffset}px"
    @$el.addClass 'canvas-view'

    @contentItemCollection = @edition.get('content_items')
    @groupCollection       = @edition.get('groups')

    # Capture all the pages & content items
    @contentItemSelector = '[data-content-item-id]'
    @groupSelector       = '[data-group-id]'
    @pageSelector        = '[data-page-id]'

    contentItemEls     = @$(@contentItemSelector).detach()
    groupEls           = @$(@groupSelector).detach()
    pageEls            = @$(@pageSelector).detach()

    @$pages = @$('[pages]') # Pages container

    @pageViews = options.pageViews
    @pageContentItems = {}                          # Inventory of content items per each page
    @pageGroups = {}                                # Inventory of content items per each page
    @groupViews = options.groupViews                # Group views by group.cid
    @contentItemViews = options.contentItemViews
    @contentItemOutlineViews = {}

    ## Add each of the pages back, rebuilding the view in the correct order.
    ## Need pages for this section, ordered by page number.
    @pages = new Backbone.Collection(section.getPages())


    @pageViewsArray = [] # Order array of the page views. # TODO: Should be a special collection.

    @pages.each (page) =>
      page_id = page.id
      el = pageEls.filter("[data-page-id='#{page_id}']")

      view = new Newstime.PageView
        el: el
        model: page

      @$pages.append(el)

      view.capturePageBounds()

      @pageViews[page.cid] = view
      @pageViewsArray.push(view)
      @pageContentItems[page.cid] = page.getContentItems()
      @pageGroups[page.cid] = page.getGroups()

      @listenTo view, 'change', => @trigger 'change'


    @$canvasItems = $('<div class="canvas-items"></div>')
    @$canvasItems.appendTo(@$body)

    # Attach a view to draw the link
    @$linkAreas = $('<div class="link-areas"></div>')
    @$linkAreas.appendTo(@$body)

    # Position canvas items div layer
    @positionCanvasItemsContainer()

    @pages.each (page) =>
      pageID = page.get('_id')
      pageView = @pageViews[page.cid]

      groups = @pageGroups[page.cid]
      contentItems = @pageContentItems[page.cid]

      _.each groups, (group) =>

        # Construct and add in each content item.
        id = group.get('_id')
        el = groupEls.filter("[data-group-id='#{id}")

        groupView = new Newstime.GroupView
          model: group
          el: el

        groupContentItems = group.getContentItems()

        # Place them in z-index order.
        groupContentItems = groupContentItems.sort (a, b) ->
          b.get('z-index') - a.get('z-index') # Reverese order on z-index (Highest towards top)

        # Add grouped content items to group
        _.each groupContentItems, (contentItem) ->

          # Construct and add in each content item.
          id = contentItem.get('_id')
          el = contentItemEls.filter("[data-content-item-id='#{id}")

          contentItemType = contentItem.get('_type')

          ## What is the content items type?
          contentItemViewType =
            switch contentItemType
              when 'HeadlineContentItem' then Newstime.HeadlineView
              when 'TextAreaContentItem' then Newstime.TextAreaView
              when 'PhotoContentItem' then Newstime.PhotoView
              when 'VideoContentItem' then Newstime.VideoView

          contentItemView = new contentItemViewType
            model: contentItem
            el: el

          groupView.addCanvasItem(contentItemView, reattach: true)


        #@listenTo group, 'destroy', (group) ->
          #@groupViews[group.cid] = null

        #groupCID = group.cid
        #@groupViews[group.id] = groupView
        #@groupOutlineViews[groupCID] = groupOutlineView

        #@$groups.append(el) # For now a seperate layer, eventually on canvas item div, with z-index coordination

        #@composer.outlineLayerView.attach(groupView.outlineView)

        @addCanvasItem(groupView, reattach: true) # Add groupView to the canvas.

      contentItems = _.reject contentItems, (item) -> item.get('group_id') # Don't process items which are part of a group...
      _.each contentItems, (contentItem) =>
        # Construct and add in each content item.
        id = contentItem.get('_id')
        el = contentItemEls.filter("[data-content-item-id='#{id}")

        contentItemType = contentItem.get('_type')

        ## What is the content items type?
        contentItemViewType =
          switch contentItemType
            when 'HeadlineContentItem' then Newstime.HeadlineView
            when 'TextAreaContentItem' then Newstime.TextAreaView
            when 'PhotoContentItem' then Newstime.PhotoView
            when 'VideoContentItem' then Newstime.VideoView

        contentItemView = new contentItemViewType
          model: contentItem
          el: el

        @addCanvasItem(contentItemView, reattach: true)

    # Add an add page button
    @addPageButton = new Newstime.AddPageButton
      composer: @composer
    @$el.append(@addPageButton.el)

    # Create link area, to enable clicking through on links.
    @linkAreas = _.map @$el.find('a'), (link) =>
      new Newstime.LinkArea(link, topOffset: @topOffset, composer: @composer)

    _.each @linkAreas, (linkArea) =>
      view = new Newstime.LinkAreaView
        model: linkArea
      view.render()
      @$linkAreas.append(view.el)

    @bindUIEvents()

    @listenTo @composer, 'zoom', @zoom
    @listenTo @contentItemCollection, 'remove', @removeContentItem
    @listenTo @groupCollection, 'add', @addGroup


    _.each @groupViews, (groupView) ->
      groupView.measurePosition()
      groupView.render()

  #addGroup: (group) ->
    #@groupViews[group.cid] =
      #new Newstime.GroupView
        #model: group

  findViewByCID: (cid) ->
    view = null
    _.find @pageViewsArray, (pageView) ->
      if pageView.cid == cid
        view = pageView
      else
        _.find pageView.contentItemViewsArray, (itemView) ->
          if itemView.cid == cid
            view = itemView
          #else
            #if itemView instanceof Newstime.GroupView
              #_.find itemView.contentItemViewsArray, (itemView) ->
                #if itemView.cid == cid
                  #view = itemView

    view

  addCanvasItem: (view, options={}) ->
    view.container = this
    @$canvasItems.append(view.el)
    @composer.outlineLayerView.attach(view.outlineView)
    @_assignPage(view, options)
    @trigger 'change'

  removeCanvasItem: (view) ->
    view.$el.detach()
    @composer.outlineLayerView.remove(view.outlineView)
    view.pageView.removeCanvasItem(view)
    view.container = null
    @trigger 'change'

  removePage: (pageView) ->
    pageView.$el.detach()
    index = @pageViewsArray.indexOf(pageView)
    if index == -1
      throw "Page view not found."
    @pageViewsArray.splice(index, 1)
    pageView.container = null
    @trigger 'change'

  # Saves changes to canvas
  save: ->
    _.each @pageViewsArray, (pageView) ->
      pageView.save()
    #@edition.save()

  # Inserts view before referenceView.
  insertBefore: (view, referenceView) ->
    # Find page with view.
    pageView = _.find @pageViewsArray, (pageView) ->
      pageView.hasView(referenceView)

    # Insert before on page.
    pageView.insertBefore(view, referenceView)

  detachView: (view) ->
    # Find page with view.
    pageView = _.find @pageViewsArray, (pageView) ->
      pageView.hasView(view)

    # Detach from page.
    pageView.detachView(view)


  removeContentItem: (contentItem) =>
    # Remove from the content items view registry.
    delete @contentItemViews[contentItem.cid]
    delete @contentItemOutlineViews[contentItem.cid]


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
    @trigger 'render'

  # Measure link areas. Right now, need to do this after render to ensure we get
  # to correct values. Should be improved.
  measureLinks: =>
    _.invoke @linkAreas, 'measure', @position

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
    @$linkAreas.css(@position)

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

      pageView = new Newstime.PageView
        el: el
        page: pageModel

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
          @draw(Newstime.TextAreaView, e.x, e.y)
        when 'headline-tool'
          @draw(Newstime.HeadlineView, e.x, e.y)
        when 'photo-tool'
          @draw(Newstime.PhotoView, e.x, e.y)
        when 'video-tool'
          @drawVideo(e.x, e.y)
        when 'select-tool'
          if e.button == 0 # Only on left click
            @composer.clearSelection()
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

    selection = null

    # Check for hit inorder to highlight hovered selection
    if @composer.activeSelectionView # Check active selection first.
      selection = @composer.activeSelectionView if @composer.activeSelectionView.hit(e.x, e.y)

    unless selection
      _.find @pageViewsArray, (pageView) ->
        selection = pageView.getHitContentItem(e.x, e.y)

    unless selection
      # NOTE: Would be nice to skip active selection here, since already
      # checked, but no biggie.
      selection = _.find @linkAreas, (linkArea) ->
        linkArea.hit(e.x, e.y)

    unless selection # If no page, check for button hit
      if @detectHit @addPageButton, e.x, e.y
        selection = @addPageButton

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

  draw: (type, x, y) ->
    view = new type()
    view.model.set(top: y, left: x)
    @addCanvasItem(view)
    @composer.select(view)
    @composer.selection.beginDraw(x, y)

    view.serverRender()


  drawSelection: (x, y) ->
    selectionView = new Newstime.Selection()
    @$el.append(selectionView.el)

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

  # Assigns a view to a page in the pageViewsArray (Note: pageViewsArray should
  # become a special collection.
  _assignPage: (view, options={}) ->
    # Determine page based on intersection.
    pageView = _.find @pageViewsArray, (pageView) =>
      @detectHitY pageView, view.model.get('top')

    pageView.addCanvasItem(view, options)
