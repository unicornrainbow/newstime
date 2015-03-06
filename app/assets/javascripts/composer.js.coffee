# ## Libraries
#= require lib/zepto
#= require lib/underscore
#= require lib/underscore_extensions
#= require lib/backbone
#= require lib/backbone-relational
#= require lib/backbone.authtokenadapter
#= require lib/jquery.elastic
#= require faye
#
# ## App
#= require newstime_util
#= require_tree ./composer/lib
#= require_tree ./composer/mixins
#= require ./composer/views/view
#= require_tree ./composer/plugins
#= require_tree ./composer/models
#= require_tree ./composer/views
#= require_tree ./composer/collections
#= require_tree ./composer/functions
#= require_tree ./composer/templates

@Newstime = @Newstime or {}

class @Newstime.Composer extends Backbone.View

  initialize: (options) ->
    # No dups
    throw "Composer instance already created." if Newstime.composer

    # Create a global reference to this instance.
    Newstime.composer = this

    @edition = options.edition
    @section = options.section

    @editionContentItems = @edition.get('content_items')

    # Create application vent for aggregating events.
    @vent = _.clone(Backbone.Events)

    @captureAuthenticityToken()

    # Capture Elements
    @$window = $(window)
    @$document = $(document)
    @$body = $('body')
    @canvas = $('.page')[0]

    ## Config
    @topOffset = 0 # 61 # px
    @menuHeight = 25

    @snapTolerance = 20 # This needs to be extracted to a configuration
    @snapEnabled = true

    @contentItemViews = {}
    @groupViews = {}
    @pageViews = {}

    @deleteQueue = [] # Queue of models to be destoryed. Flushed with each save.

    @groupViewCollection   = new Newstime.GroupViewCollection()
    @pageViewCollection   = new Newstime.PageViewCollection()
    @outlineViewCollection = new Newstime.OutlineViewCollection()

    @toolbox = new Newstime.Toolbox

    # Create application layers
    @captureLayerView = new Newstime.CaptureLayerView
      composer: this
      topOffset: @topOffset
    @$body.append(@captureLayerView.el)

    @menuLayerView = new Newstime.MenuLayerView
      composer: this
      topOffset: @topOffset
    @$body.append(@menuLayerView.el)
    @menuLayerView.trigger 'attach'

    @panelLayerView = new Newstime.PanelLayerView
      composer: this
      topOffset: @topOffset + @menuHeight
    @$body.append(@panelLayerView.el)

    @selectionLayerView = new Newstime.SelectionLayerView
      composer: this
    @$body.append(@selectionLayerView.el)

    @outlineLayerView = new Newstime.OutlineLayerView
      composer: this
    @$body.append(@outlineLayerView.el)

    @canvasLayerView = @canvas = new Newstime.CanvasView
      el: @canvas
      topOffset: @topOffset + @menuHeight
      edition: @edition
      toolbox: @toolbox
      contentItemViews: @contentItemViews
      groupViews: @groupViews
      pageViews: @pageViews
    @$body.append(@canvasLayerView.el)

    @hasFocus = true # By default, composer has focus

    @keyboardHandler = new Newstime.KeyboardHandler
      composer: this

    @statusIndicator = new Newstime.StatusIndicatorView()
    @$body.append(@statusIndicator.el)

    # Initialize Plugins
    $("#edition-toolbar").editionToolbar(composer: this)
    $("#edition-toolbar").hide() # Hiding for now while testing.
    $("#section-nav").sectionNav()

    ## Build Panels
    @toolboxView = new Newstime.ToolboxView
      composer: this
      model: @toolbox
    @panelLayerView.attachPanel(@toolboxView)

    @propertiesPanelView = new Newstime.PropertiesPanelView
      composer: this

    @propertiesPanelView.setPosition(50, 20)
    @panelLayerView.attachPanel(@propertiesPanelView)
    @propertiesPanelView.show()

    @pagesPanelView = new Newstime.PagesPanelView
    @pagesPanelView.setPosition(250, 20)
    @panelLayerView.attachPanel(@pagesPanelView)

    @sectionSettings = new Newstime.SectionSettingsWindowView
    @sectionSettings.setPosition(50, 200)
    @panelLayerView.attachPanel(@sectionSettings)
    @sectionSettings.hide()

    @editionSettings = new Newstime.EditionSettingsWindowView
    @editionSettings.setPosition(50, 200)
    @panelLayerView.attachPanel(@editionSettings)
    @editionSettings.hide()

    @printsWindow = new Newstime.PrintsWindowView
    @printsWindow.setPosition(50, 200)
    @panelLayerView.attachPanel(@printsWindow)
    @printsWindow.hide()

    @cursorStack = []
    @focusStack = []

    #@zoomLevels = [25, 33, 50, 67, 75, 90, 100, 110, 125, 150, 175, 200, 250, 300, 400, 500]
    @zoomLevels = [25, 33, 50, 67, 75, 90, 100]
    @zoomLevelIndex = 6

    ## Bind events

    @$window.resize => @windowResize()
    $(document).on "paste", @paste

    @textEditor = new Newstime.TextAreaEditorView
      composer: this
    @$body.append(@textEditor.el)


    # Layers of app, in order from top to bottom
    @layers = [
      @textEditor
      @menuLayerView
      @panelLayerView
      @canvasLayerView
    ]

    @listenTo @captureLayerView, 'mouseup', @mouseup
    @listenTo @captureLayerView, 'mousemove', @mousemove
    @listenTo @captureLayerView, 'mousedown', @mousedown
    @listenTo @captureLayerView, 'contextmenu', @contextmenu
    @listenTo @captureLayerView, 'dblclick', @dblclick

    _.each @layers, (layer) =>
      @listenTo layer, 'tracking',         @tracking
      @listenTo layer, 'tracking-release', @trackingRelease
      @listenTo layer, 'focus',            @handleLayerFocus

    @listenTo @edition, 'sync', @editionSync
    @listenTo @edition, 'change', @editionChange

    window.onbeforeunload = =>
      if @edition.isDirty()
        return "You have unsaved changes."

    @listenTo @vent, "edit-text", @editText

    # Intialize App

    @repositionScroll()
    @toolbox.set(selectedTool: 'select-tool')
    @toolboxView.show()

    @vent.trigger 'ready'

  editionSync: ->
    @statusIndicator.showMessage "Saved", 1000
    @statusIndicator.unsavedChanged(false)

  editionChange: ->
    @statusIndicator.unsavedChanged(true)

  render: ->
    @canvasLayerView.render()

  editText: (model) ->
    # Ensure initial text area incase connected
    model = model.initialTextArea()

    @textEditor.setModel(model)
    @textEditor.show()
    #console.log this
    #Newstime.Composer.textEditor.show()
    # Display Text Area Editor
    # Attach model
    # Copy over values into a local model for the editor.
    # When they exit, save changes back to model, which will update view.

  windowResize: ->
    @canvasLayerView.trigger 'windowResize'
    @menuLayerView.trigger 'windowResize'

  # Focus on composer
  focus: ->
    $(document.activeElement).blur()
    @hasFocus = true

  blur: ->
    @hasFocus = false

  handleLayerFocus: (layer) =>
    @focusedObject = layer

  # Called when keydown and composer hasFocus
  keydown: (e) ->

    if @focusedObject
      @focusedObject.trigger 'keydown', e

    unless e.isPropagationStopped()
      switch e.keyCode
        when 83 # s
          if e.ctrlKey || e.altKey # ctrl+s
            @save()

  save: ->
    @statusIndicator.showMessage "Saving"

    # Flush delete queue
    if @deleteQueue.length > 0
      model = @deleteQueue.shift()
      model.destroy
        success: =>
          @save()
        error: =>
          @deleteQueue.unshift(model)
          @save()
    else
      # Find unsaved group
      newGroup = @edition.get('groups').find (g) -> g.isNew()

      if newGroup
        # Save the group, and call us back on success
        newGroup.save {},
          success: (model) =>
            @save()
      else
        @edition.save()

  paste: (e) =>
    if @focusedObject
      @focusedObject.trigger 'paste', e

  displayContextMenu: (contextMenu) ->
    @currentContextMenu = contextMenu

  selectedToolChanged: ->
    @updateCursor()

  tracking: (layer) ->
    @trackingLayer = layer

  trackingRelease: (layer) ->
    @trackingLayer = null


  captureAuthenticityToken: ->
    @authenticityToken = $("input[name=authenticity_token]").first().val()
    return

  toggleGridOverlay: ->
    @gridOverlay.toggle()
    return

  hideCursor: ->
    @captureLayerView.hideCursor()

  showCursor: ->
    @captureLayerView.showCursor()

  changeCursor: (cursor) ->
    @currentCursor = cursor
    @captureLayerView.changeCursor(@currentCursor)

  lockScroll: ->
    $('body').css({'overflow':'hidden'})

  unlockScroll: ->
    $('body').css({'overflow':''})

  pushCursor: (cursor) ->
    @cursorStack.push @currentCursor
    @changeCursor(cursor)

  popCursor: ->
    cursor = @cursorStack.pop()
    @changeCursor(cursor)

  pushFocus: (target) ->
    @focusStack.push @focusedObject
    @focusedObject = target

  popFocus: ->
    @focusedObject = @focusStack.pop()

  launchPreview: ->
    url = window.location.toString().replace('compose', 'preview')
    window.open(url, '_blank')

  # Sets the UI cursor accoring to a set of rules.
  #updateCursor: ->
    #cursor = switch @toolbox.get('selectedTool')
      #when 'select-tool' then 'default'
      #when 'text-tool' then 'text'

    #@changeCursor(cursor)


  # Public: Handles mousemove events, called by CaptureLayerView
  mousemove: (e) ->

    # Store current cursor location.
    @mouseX = e.x
    @mouseY = e.y

    # Compensate for top offset to allow room for menu
    e =
      x: @mouseX
      y: @mouseY
      shiftKey: e.shiftKey

    # If tracking layer, pass event there and return.
    if @trackingLayer
      @trackingLayer.trigger 'mousemove', e
      return true

    # Test layers of app to determine where to direct the hit.
    hit = _.find @layers, (layer) => layer.hit(@mouseX, @mouseY)

    if hit
      if @hitLayer != hit
        if @hitLayer
          @hitLayer.trigger 'mouseout', e
        @hitLayer = hit
        @hitLayer.trigger 'mouseover', e

    else
      if @hitLayer
        @hitLayer.trigger 'mouseout', e
        @hitLayer = null


    # Pass mousemove through to the hit layer
    if @hitLayer
      @hitLayer.trigger 'mousemove', e

      # Clear cursor state
      #@changeCursor('')


  mousedown: (event) ->
    @hasFocus = true
    e =
      x: @mouseX
      y: @mouseY
      button: event.button
      shiftKey: event.shiftKey

    if @selectedMenu && @hitLayer != @menuLayerView
      @selectedMenu.close()
      @selectedMenu = null

    if @currentContextMenu
      @currentContextMenu.hide()
      @currentContextMenu = null

    if @trackingLayer
      # For the time being, block mousedowns while tracking
      return true

    # TODO: Rather than tracking an relying to the hovered object, we need to track
    # which if the layers gets the hit, and pass down to it for delegation to
    # the individual object.
    if @hitLayer
      @hitLayer.trigger 'mousedown', e

  dblclick: (event) ->
    e =
      x: @mouseX
      y: @mouseY
      button: event.button

    if @trackingLayer
      # For the time being, block dblclicks while tracking
      return true

    if @hitLayer
      @hitLayer.trigger 'dblclick', e


  contextmenu: (e) ->
    event = e
    e =
      x: @mouseX
      y: @mouseY
      preventDefault: ->
        event.preventDefault()

    if @hitLayer
      @hitLayer.trigger 'contextmenu', e


  mouseup: (e) ->
    e =
      x: @mouseX
      y: @mouseY

    if @trackingLayer
      @trackingLayer.trigger 'mouseup', e
      return true

    # TODO: Rather than tracking an relaying to the hovered object, we need to
    # track which of the layers gets the hit, and pass down to it for delegation
    # to the individual object.
    if @hitLayer
      @hitLayer.trigger 'mouseup', e

  zoomIn: ->
    @zoomLevelIndex ?= 0
    @zoomLevelIndex = Math.min(@zoomLevelIndex+1, @zoomLevels.length-1)
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100
    @trigger 'zoom'
    #@repositionScroll()


  setZoomLevelIndex: (zoomLevelIndex) ->
    @zoomLevelIndex = zoomLevelIndex
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100
    @trigger 'zoom'

  zoomOut: ->
    @zoomLevelIndex ?= 0
    @zoomLevelIndex = Math.max(@zoomLevelIndex-1, 0)
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100
    @trigger 'zoom'
    #@repositionScroll()

  #zoomInPoint: (x, y) ->
    #@zoomLevelIndex ?= 0
    #@zoomLevelIndex = Math.min(@zoomLevelIndex+1, 10)
    #@zoomLevel = @zoomLevels[@zoomLevelIndex]/100

    #@trigger 'zoom'

    ## Lock scroll horizontally
    ##documentWidth = document.body.scrollWidth # scroll width give the correct width, considering auto margins on resize, versus document width
    #documentWidth = $(document).width() # scroll width give the correct width, considering auto margins on resize, versus document width
    #windowWidth   = $(window).width()
    #@scrollLeft   = $(window).scrollLeft()


    #if documentWidth - windowWidth == 0
      ## Assumed scroll position with no scroll is 50%
      #@horizontalScrollPosition = 50
    #else
      ## Apply scroll position
      ##scrollLeft = (documentWidth - windowWidth) * (@horizontalScrollPosition/100)
      #@scrollLeft = (documentWidth - windowWidth) * x/windowWidth


      #$(window).scrollLeft(@scrollLeft)

    ## Lock scroll vertically

    #documentHeight = Math.round(document.body.scrollHeight)
    #windowHeight   = Math.round($(window).height())
    #@scrollTop   = Math.round($(window).scrollTop())

    #if documentHeight - windowHeight == 0
      ## Assumed scroll position with no scroll is 50%
      #@verticalScrollPosition = 50
    #else
      ## Apply scroll position
      ##scrollTop = (documentHeight - windowHeight) * (@verticalScrollPosition/100)
      ## Need to compensate for menu bar up top...
      ##scrollTop = (documentHeight - windowHeight) * y/windowHeight
      ##$(window).scrollTop(scrollTop)


  zoomToPoint: (x, y) ->
    @zoomLevelIndex ?= 0
    @zoomLevelIndex = @zoomLevelIndex+1
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100
    @trigger 'zoom'


  zoomReset: ->
    @zoomLevelIndex = 6
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100
    @trigger 'zoom'
    #@repositionScroll()


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

  # Adds a new page
  addPage: ->
    # Get next page number
    number = @section.getNextPageNumber()
    pageView = @pageViewCollection.add({})
    pageView.model.set 'section_id', @section.id
    pageView.model.set 'number', number

    # TODO: Render offline page
    #pageView.model.getHTML (html) =>
      #el = $(html)[0]
      #@canvas.$pages.append(el)

    # Append page
    @canvas.$pages.append(pageView.el)
    @canvas.pageViewsArray.push(pageView)
    @pagesPanelView.renderPanel()

    # Render page from server
    $.ajax
      method: 'GET'
      url: "#{@edition.url()}/render_page.html"
      data:
        composing: true
        page: pageView.model.toJSON()
      success: (response) =>
        # Parse response into element.
        el = @_parseHTML(response)

        # Attach and render
        pageView.$el.replaceWith(el)
        pageView.setElement(el)
        pageView.render()

        @canvas.positionCanvasItemsContainer()



  # Utility Method: Parses html in to dom element.
  _parseHTML: (html) ->
    div = document.createElement('div')
    div.innerHTML = html
    div.firstChild

  # Receives a collection of models to group
  createGroup: (items) ->
    group = new Newstime.Group()
    group.addItems(items)
    return group

    #page_id = _.first(models).get('page_id') # HACK: Assign group to page for first item for now.
    #group = @edition.get('groups').create { page_id: page_id },
      #success: (group) ->
        #_.each models, (model) ->
          #model.set(group_id: group.get('_id'))

        #success(group) if success

  getView: (model) =>
    if model instanceof Newstime.ContentItem
      @contentItemViews[model.cid]
    else if model instanceof Newstime.Group
      @groupViews[model.cid]
    else if model instanceof Newstime.Page
      @pageViews[model.cid]

  selectPage: (pageView) ->
    @clearSelection()
    @selection = pageView
    @focusedObject = pageView
    pageView.selected = true

    @updatePropertiesPanel(@selection)

  select: (contentItemViews...) ->
    contentItemView = _.first(contentItemViews)

    @clearSelection()

    @selection = @activeSelectionView = new Newstime.SelectionView
      contentItemView: contentItemView

    @activeSelectionView.render()

    @updatePropertiesPanel(@activeSelectionView)

    contentItemView.select(@activeSelectionView)

    @selectionLayerView.setSelection(@activeSelectionView)
    @focusedObject = @activeSelectionView  # Set focus to selection to send keyboard events.

    @canvasLayerView.listenTo @activeSelectionView, 'tracking', @canvasLayerView.resizeSelection
    @canvasLayerView.listenTo @activeSelectionView, 'tracking-release', @canvasLayerView.resizeSelectionRelease
    @listenTo @activeSelectionView, 'destroy', @clearSelection

    rest = _.rest(contentItemViews)

    if rest.length > 0
      @addToSelection.apply this, rest
    else
      @pagesPanelView.render()


  # Adds model to a selection.
  addToSelection: (contentItemViews...) ->
    # Just do normal selection if nothing is selected.
    unless @activeSelectionView
      @select.apply this, arguments
      return

    # Convert ContentItem selection to multiselection
    if @activeSelectionView instanceof Newstime.SelectionView
      contentItemView = @activeSelectionView.contentItemView

      @clearSelection()

      multiSelectionView = new Newstime.MultiSelectionView()
      multiSelectionView.addView(contentItemView)
      contentItemView.select(multiSelectionView)

      @selection = @activeSelectionView = multiSelectionView

      @activeSelectionView.render()

      @selectionLayerView.setSelection(@activeSelectionView)

      @updatePropertiesPanel(@activeSelectionView)
      @focusedObject = @activeSelectionView  # Set focus to selection to send keyboard events.

      @canvasLayerView.listenTo @activeSelectionView, 'tracking', @canvasLayerView.resizeSelection
      @canvasLayerView.listenTo @activeSelectionView, 'tracking-release', @canvasLayerView.resizeSelectionRelease
      @listenTo @activeSelectionView, 'destroy', @clearSelection

    _.each contentItemViews, (view) =>
      @activeSelectionView.addView(view)
      view.select(@activeSelectionView)

    @pagesPanelView.render()

  # Removes model from selection.
  removeFromSelection: (model) ->
    # TODO: Implement.

  clearSelection: ->
    if @selection?
      @activeSelectionView?.remove()
      @propertiesPanelView.clear()
      @activeSelectionView = null
      @selection = null
    @pagesPanelView.render()

  updatePropertiesPanel: (target) ->
    propertiesView = target.getPropertiesView()
    @propertiesPanelView.mount(propertiesView)

  togglePanelLayer: ->
    @panelLayerView.toggle()

    menuItem = @menuLayerView.menuView.viewTitleView.panelsMenuItem

    if @panelLayerView.hidden
      menuItem.title = "Show Panels"
    else
      menuItem.title = "Hide Panels"


    menuItem.render()

  # Returns array of pages which intersect with the bounding box.
  getIntersectingPages: (top, left, bottom, right) ->
    # Get all pages from section
    pages = @section.getPages()

    # Return where pages collide.
    _.filter pages, (page) ->
      page.collide(top, left, bottom, right)


  enableSnap: ->
    @snapEnabled = true
    @vent.trigger 'config:snap:enabled'

  disableSnap: ->
    @snapEnabled = false
    @vent.trigger 'config:snap:disabled'

  # Reflows all text in the edition
  reflow: ->
    # Get all text areas
    textAreas = @edition.get('content_items').select (item) ->
      item.get('_type') == 'TextAreaContentItem'

    # Group them by title
    grouped = _.groupBy textAreas, (item) ->
      item.get('story_title')

    _.each grouped, (value, key) ->
      # Put in correct order
      value = value.sort (a, b) ->
        if a.getSection().get('sequence') != b.getSection().get('sequence')
          a.getSection().get('sequence') - b.getSection().get('sequence')
        else if a.getPage().get('number') != b.getPage().get('number')
          a.getPage().get('number') - b.getPage().get('number')
        else if a.get('top') != b.get('top')
          a.get('top') - b.get('top')
        else
          a.get('left') - b.get('left')

      # Trigger reflow from first item in set
      _.first(value).reflow()


  toggleSectionSettings: ->
    @sectionSettings.toggle()

  toggleEditionSettings: ->
    @editionSettings.toggle()

  togglePrintsWindow: ->
    @printsWindow.toggle()

  moveItem: (target, left, top, orginalLeft, orginalTop, shiftKey=false) ->
    @clearVerticalSnapLines()

    # TODO: Move guidelines to their own layer (Fixed position, but which
    # handles zooming)

    bounds = target.getBounds()
    width = bounds.right - bounds.left
    right = left + width

    if shiftKey
      # In which direction has the greatest movement.
      lockPlain = if Math.abs(left - orginalLeft) > Math.abs(top - orginalTop) then 'x' else 'y'

    # TODO: Need a better direction lock algorythm.
    switch lockPlain
      when 'x'
        # Move only in x direction
        target.setSizeAndPosition
          left: left
          top: orginalTop
      when 'y'
        # Move only in y direction
        target.setSizeAndPosition
          left: orginalLeft
          top: top
      else

        # Compute snaps against left and right for each intersecting page, and
        # take closest snap within tolerence.

        # Which pages are we intersecting?
        pages = @getIntersectingPages(top, left, bounds.bottom, bounds.right)

        # 1 Get all of the left snap points, and right snap points for each of the
        # intersecting pages.
        leftSnapPoints = _.map pages, (page) =>
          @pageViews[page.cid].getLeftSnapPoints() # Should we know snap points at the model level? Would be useful in this calulation
        rightSnapPoints = _.map pages, (page) =>
          @pageViews[page.cid].getRightSnapPoints()

        leftSnapPoints  = _.union(leftSnapPoints)
        rightSnapPoints = _.union(rightSnapPoints)

        leftSnapPoints = _.flatten(leftSnapPoints)
        rightSnapPoints = _.flatten(rightSnapPoints)

        leftSnap = Newstime.closest(left, leftSnapPoints)
        rightSnap = Newstime.closest(right, rightSnapPoints)

        leftSnapDelta = Math.abs(leftSnap - left)
        rightSnapDelta = Math.abs(rightSnap - right)

        if leftSnapDelta < rightSnapDelta
          if leftSnapDelta <= @snapTolerance
            # Snap to left
            left = leftSnap
        else
          if rightSnapDelta <= @snapTolerance
            # Snap to right
            left = rightSnap - width

        # Highlight snap lines
        if _.contains(leftSnapPoints, left)
          @drawVerticalSnapLine(left)

        right = left + width
        if _.contains(rightSnapPoints, right)
          @drawVerticalSnapLine(right)

        target.setSizeAndPosition # TODO: See if we can go direct to model
          left: left
          top: top



  # Sets toolbox tool
  #
  # Example:
  #
  #   @composer.setTool('select-tool')
  #
  setTool: (tool) ->
    @toolbox.set(selectedTool: tool)

  drawVerticalSnapLine: (x) ->
    @outlineLayerView.drawVerticalSnapLine(x)

  clearVerticalSnapLines: ->
    @outlineLayerView.clearVerticalSnapLines()

  # Ensure item is on correct page, otherwise reassigns page
  assignPage: (canvasItem) ->
    y = canvasItem.top

    # Get section pages
    sectionPages = @section.getPages()

    # Page must have an offset less than or equal to the y position of the page
    # to be a match foe the page it appears on. Pages are stacked consecutive,
    # so we are looking for the highest offset, selected in next step.
    pages = _.filter sectionPages, (page) ->
      page.top <= y

    # Take the page with the highest offet out of qualifying pages
    page = _.max pages, (page) -> page.top

    if canvasItem.getPage() != page
      canvasItem.setPage(page)



$ ->
  # Get the edition, mostly for development purposes right now.
  #edition_id = document.URL.match(/editions\/(\w*)/)[1] # Hack to get edition id from url string
  #window.edition = new Newstime.Edition({_id: edition_id})

  window.edition = new Newstime.Edition(editionJSON)
  window.edition.dirty = false # HACK: To make sure isn't considered dirty after initial creation

  # Global reference to current section model
  window.section =  edition.get('sections').findWhere(_id: composer.sectionID)

  new Newstime.Composer(edition: edition, section: section)

  # Delay render by 200 millisecond. This is mostly because of time needed for
  # fonts to load in order to measure. Need to properly handle events in the
  # future o detect loading of fonts, to avoid hacks like this. This will work
  # for now.
  setTimeout _.bind(Newstime.composer.render, Newstime.composer), 200

  return
