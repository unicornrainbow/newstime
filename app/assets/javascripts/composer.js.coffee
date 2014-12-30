# ## Libraries
#= require lib/zepto
#= require lib/underscore
#= require lib/backbone
#= require lib/backbone-relational
#= require lib/backbone.authtokenadapter
#= require lib/jquery.elastic
#= require faye
#
# ## App
#= require newstime_util
#= require_tree ./composer/plugins
#= require_tree ./composer/models
#= require_tree ./composer/views
#= require_tree ./composer/functions

@Newstime = @Newstime or {}

class @Newstime.Composer extends Backbone.View

  initialize: (options) ->
    @edition = options.edition
    @section = options.section

    @editionContentItems = @edition.get('content_items')

    # Create application vent for aggregating events.
    @vent = _.extend({}, Backbone.Events)

    @captureAuthenticityToken()

    # Capture Elements
    @$window = $(window)
    @$document = $(document)
    @$body = $('body')
    @canvas = $('.page')[0]

    ## Config
    @topOffset = 0 # 61 # px
    @menuHeight = 25

    @contentItemViews = {}

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

    @canvasLayerView = new Newstime.CanvasLayerView
      el: @canvas
      composer: this
      topOffset: @topOffset + @menuHeight
      edition: @edition
      toolbox: @toolbox
      contentItemViews: @contentItemViews
    @$body.append(@canvasLayerView.el)

    @hasFocus = true # By default, composer has focus

    @keyboardHandler = new Newstime.KeyboardHandler
      composer: this

    @statusIndicator = new Newstime.StatusIndicatorView()
    @$body.append(@statusIndicator.el)


    @verticalSnapLine = new Newstime.VerticalSnapLine()
    @canvasLayerView.$el.append @verticalSnapLine.el
    @verticalSnapLine.hide()

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

    @captureLayerView.bind 'mouseup', @mouseup, this
    @captureLayerView.bind 'mousemove', @mousemove, this
    @captureLayerView.bind 'mousedown', @mousedown, this
    @captureLayerView.bind 'contextmenu', @contextmenu, this
    @captureLayerView.bind 'dblclick', @dblclick, this


    _.each @layers, (layer) =>
      layer.bind 'tracking',         @tracking, this
      layer.bind 'tracking-release', @trackingRelease, this
      layer.bind 'focus',            @handleLayerFocus, this

    @edition.bind 'sync', @editionSync, this
    @edition.bind 'change', @editionChange, this

    @editionContentItems.bind 'remove', @removeContentItem

    window.onbeforeunload = =>
      if @edition.isDirty()
        return "You have unsaved changes."

    @vent.on "edit-text", @editText, this

    # Intialize App

    @repositionScroll()
    @toolbox.set(selectedTool: 'select-tool')
    @toolboxView.show()

  removeContentItem: (contentItem) =>
    # Remove from the content items view registry.
    delete @contentItemViews[contentItem.cid]

  editionSync: ->
    @statusIndicator.showMessage "Saved", 1000
    @statusIndicator.unsavedChanged(false)

  editionChange: ->
    @statusIndicator.unsavedChanged(true)

  render: ->
    @canvasLayerView.render()

  editText: (model) ->
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
            @edition.save() # Save edition
            @statusIndicator.showMessage "Saving"

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

    # Compistae for top offset to allow room for menu

    e =
      x: @mouseX
      y: @mouseY

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
    @section.addPage (page) =>
      @canvasLayerView.addPage(page)

  select: (contentItem) ->
    @clearSelection()

    contentItemCID = contentItem.cid
    contentItemView = @contentItemViews[contentItemCID]

    selection = new Newstime.ContentItemSelection
      contentItem: contentItem
      contentItemView: contentItemView

    @activeSelection = selection

    @updatePropertiesPanel(@activeSelection)

    @activeSelectionView = new Newstime.SelectionView
      composer: this
      selection: selection

    contentItemView.select(@activeSelectionView)

    @selectionLayerView.setSelection(selection, @activeSelectionView)
    @focusedObject = @activeSelectionView  # Set focus to selection to send keyboard events.

    @activeSelectionView.bind 'tracking', @canvasLayerView.resizeSelection, @canvasLayerView
    @activeSelectionView.bind 'tracking-release', @canvasLayerView.resizeSelectionRelease, @canvasLayerView
    @activeSelectionView.bind 'destroy', @clearSelection, this

  clearSelection: ->
    if @activeSelection?
      @activeSelection.destroy()
      @activeSelectionView.destroy()
      @propertiesPanelView.clear()
      @activeSelection = null
      @activeSelectionView = null

  updatePropertiesPanel: (target) ->
    propertiesView = target.getPropertiesView()
    @propertiesPanelView.mount(propertiesView)

  togglePanelLayer: ->
    @panelLayerView.toggle()

  # Sets toolbox tool
  #
  # Example:
  #
  #   @composer.setTool('select-tool')
  #
  setTool: (tool) ->
    @toolbox.set(selectedTool: tool)

  showVerticalSnapLine: (x) ->
    @verticalSnapLine.set(x)
    @verticalSnapLine.show()

  hideVerticalSnapLine: ->
    @verticalSnapLine.hide()

$ ->
  # Get the edition, mostly for development purposes right now.
  #edition_id = document.URL.match(/editions\/(\w*)/)[1] # Hack to get edition id from url string
  #window.edition = new Newstime.Edition({_id: edition_id})

  window.edition = new Newstime.Edition(editionJSON)
  window.edition.dirty = false # HACK: To make sure isn't considered dirty after initial creation

  # Global reference to current section model
  window.section =  edition.get('sections').findWhere(_id: composer.sectionID)

  Newstime.composer = new Newstime.Composer(edition: edition, section: section)

  # Delay render by 200 millisecond. This is mostly because of time needed for
  # fonts to load in order to measure. Need to properly handle events in the
  # future o detect loading of fonts, to avoid hacks like this. This will work
  # for now.
  setTimeout _.bind(Newstime.composer.render, Newstime.composer), 200

  return
