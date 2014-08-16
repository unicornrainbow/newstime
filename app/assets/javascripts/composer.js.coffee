# ## Libraries
#= require lib/zepto
#= require lib/underscore
#= require lib/backbone
#= require faye
#
# ## App
#= require newstime_util
#= require_tree ./composer/plugins
#= require_tree ./composer/models
#= require_tree ./composer/views

@Newstime = @Newstime or {}

@Newstime.Composer =
  init: ->
    @captureAuthenticityToken()

    # Capture Elements
    @$window = $(window)
    @$document = $(document)
    @$body = $('body')
    @$zoomTarget = $('.page')

    ## Config
    @topOffset = 62 # px
    @zoomLevels = [100, 110, 125, 150, 175, 200, 250, 300, 400, 500]


    # Create application layers
    @coverLayerView = new Newstime.CoverLayerView
      composer: this
      topOffset: @topOffset
    @$body.append(@coverLayerView.el)

    @panelLayerView = new Newstime.PanelLayerView
      composer: this
      topOffset: @topOffset
    @$body.append(@panelLayerView.el)

    @canvasLayerView = new Newstime.CanvasLayerView
      composer: this
      topOffset: @topOffset
    @$body.append(@canvasLayerView.el)


    @globalKeyboardDispatch = new Newstime.GlobalKeyboardDispatch
      composer: this

    #@zoomHandeler = new Newstime.CtrlZoomHandler
      #composer: this


    canvasDragView = new Newstime.CanvasDragView
      composer: this

    @globalKeyboardDispatch.bind 'dragModeEngaged', ->
      canvasDragView.engage()

    @globalKeyboardDispatch.bind 'dragModeDisengaged', ->
      canvasDragView.disengage()

    #@eventEmitter = new Newstime.EventEmitter (Mouse events, Keyboard Events,
    #Scroll Events)

    #var composerModals = $(".composer-modal"),
    #contentRegionModal = $(".add-content-region"),
    #contentItemModal = $(".add-content-item").contentModal();


    Newstime.Composer.globalKeyboardDispatch = @globalKeyboardDispatch
    Newstime.Composer.keyboard = new Newstime.Keyboard(defaultFocus: @globalKeyboardDispatch)
    #keyboard.pushFocus(textRegion) // example

    # Initialize Plugins
    $("#edition-toolbar").editionToolbar()
    $("#section-nav").sectionNav()

    #$("[headline-control]").headlineControl headlineProperties
    #storyPropertiesView = new Newstime.StoryPropertiesView()
    #$("[story-text-control]").each (i, el) ->
      #new Newstime.StoryTextControlView(
        #el: el
        #toolPalette: storyPropertiesView
      #)
      #return

    #contentRegionPropertiesView = new Newstime.ContentRegionPropertiesView()
    #$("[content-region-control]").each (i, el) ->
      #new Newstime.ContentRegionControlView(
        #el: el
        #propertiesView: contentRegionPropertiesView
      #)
      #return

    #photoPropertiesView = new Newstime.PhotoPropertiesView()
    #$("[photo-control]").each (i, el) ->
      #new Newstime.PhotoControlView(
        #el: el
        #propertiesView: photoPropertiesView
      #)
      #return

    #$("[page-compose]").each (i, el) =>
      #new Newstime.PageComposeView(
        #el: el
        #coverLayerView: @coverLayerView
      #)
      #return

    #@gridOverlay = $(".grid-overlay").hide()

    ## Init panels
    #@toolboxView = new Newstime.ToolboxView
      #composer: this
    #@panelLayerView.attachPanel(@toolboxView)
    #@toolboxView.show()

    #@propertiresPanelView = new Newstime.PropertiesPanelView
      #composer: this
    #@panelLayerView.attachPanel(@propertiesPanelView)
    #@propertiesPanelView.show()

    @repositionScroll()

    # Events
    #$(window).scroll(@captureScrollPosition)

  captureAuthenticityToken: ->
    @authenticityToken = $("input[name=authenticity_token]").first().val()
    return

  toggleGridOverlay: ->
    @gridOverlay.toggle()
    return

  hideCursor: ->
    @coverLayerView.hideCursor()

  showCursor: ->
    @coverLayerView.showCursor()

  changeCursor: (cursor) ->
    @coverLayerView.changeCursor(cursor)


  mousemove: (e) ->

    # Store current cursor location.
    @mouseX = e.x
    @mouseY = e.y - @topOffset

    e =
      x: @mouseX
      y: @mouseY

    # Check for a hit on panel layer
    hit = @panelLayerView.hit(e.x, e.y)


    # Check for hit on canvas layer
    #hit = @canvasLayerView.hit(e.x, e.y)


    if hit
      # Store as hoveredObject and trigger mouseout, mouseover events
      if @hoveredObject != hit
        if @hoveredObject
          @hoveredObject.trigger 'mouseout', {}

        @hoveredObject = hit
        @hoveredObject.trigger 'mouseover', {}

    else

      # Clear hovered object, if there is one.
      if @hoveredObject
        @hoveredObject.trigger 'mouseout', {}
        @hoveredObject = null

      # Clear cursor state
      @changeCursor('')

  mousedown: (e) ->
    e =
      x: @mouseX
      y: @mouseY

    if @hoveredObject
      @hoveredObject.trigger 'mousedown'


  ## Zoom stuff below for the moment

  captureScrollPosition: (e) =>

    # If calibrated, recalulate scroll poisiton
    documentWidth = document.body.scrollWidth # scroll width give the correct width, considering auto margins on resize, versus document width
    windowWidth   = $(window).width()
    scrollLeft   = $(window).scrollLeft()

    if documentWidth - windowWidth > 0
      @horizontalScrollPosition = Math.round(100 * scrollLeft / (documentWidth - windowWidth))
    else
      @horizontalScrollPosition = 50


    documentHeight = document.body.scrollHeight
    windowHeight  = $(window).height()
    scrollTop   = $(window).scrollTop()

    if documentHeight - windowHeight > 0
      @verticalScrollPosition = Math.round(100 * scrollTop / (documentHeight - windowHeight))
    else
      @verticalScrollPosition = 50

  zoomIn: ->
    # This is a demo implementation, just to test the idea
    @zoomLevelIndex ?= 0
    @zoomLevelIndex = Math.min(@zoomLevelIndex+1, 10)
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100

    # And apply zoom level to the zoom target (page)
    @$zoomTarget.css
      zoom: "#{@zoomLevel * 100}%"

    @repositionScroll()

  zoomInPoint: (x, y) ->
    # This is a demo implementation, just to test the idea
    @zoomLevelIndex ?= 0
    @zoomLevelIndex = Math.min(@zoomLevelIndex+1, 10)
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100

    # And apply zoom level to the zoom target (page)
    @$zoomTarget.css
      zoom: "#{@zoomLevel * 100}%"

    # Lock scroll horizontally
    #documentWidth = document.body.scrollWidth # scroll width give the correct width, considering auto margins on resize, versus document width
    documentWidth = $(document).width() # scroll width give the correct width, considering auto margins on resize, versus document width
    windowWidth   = $(window).width()
    scrollLeft   = $(window).scrollLeft()


    if documentWidth - windowWidth == 0
      # Assumed scroll position with no scroll is 50%
      @horizontalScrollPosition = 50
    else
      # Apply scroll position
      #scrollLeft = (documentWidth - windowWidth) * (@horizontalScrollPosition/100)
      scrollLeft = (documentWidth - windowWidth) * x/windowWidth


      $(window).scrollLeft(scrollLeft)

    # Lock scroll vertically

    documentHeight = Math.round(document.body.scrollHeight)
    windowHeight   = Math.round($(window).height())
    scrollTop   = Math.round($(window).scrollTop())

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
    @$zoomTarget.css
      zoom: "#{@zoomLevel * 100}%"

    @repositionScroll()

  repositionScroll: ->

    # Lock scroll horizontally
    #documentWidth = document.body.scrollWidth # scroll width give the correct width, considering auto margins on resize, versus document width
    documentWidth = @$document.width() # scroll width give the correct width, considering auto margins on resize, versus document width
    windowWidth   = @$window.width()
    scrollLeft   = @$window.scrollLeft()

    if documentWidth - windowWidth == 0
      # Assumed scroll position with no scroll is 50%
      @horizontalScrollPosition = 50
    else
      # Apply scroll position
      scrollLeft = (documentWidth - windowWidth) * (@horizontalScrollPosition/100)
      @$window.scrollLeft(scrollLeft)

    # Lock scroll vertically

    documentHeight = Math.round(document.body.scrollHeight)
    windowHeight   = Math.round($(window).height())
    scrollTop   = Math.round($(window).scrollTop())

    if documentHeight - windowHeight == 0
      # Assumed scroll position with no scroll is 50%
      @verticalScrollPosition = 50
    else
      # Apply scroll position
      scrollTop = (documentHeight - windowHeight) * (@verticalScrollPosition/100)
      $(window).scrollTop(scrollTop)

  zoomReset: ->
    @zoomLevelIndex = 0
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100

    # And apply zoom level to the zoom target (page)
    @$zoomTarget.css
      zoom: "#{@zoomLevel * 100}%"

    @repositionScroll()

  zoomToPoint: (x, y) ->
    # This is a demo implementation, just to test the idea

    @zoomLevelIndex ?= 0
    @zoomLevelIndex = @zoomLevelIndex+1
    zoomLevels = [100, 110, 125, 150, 175, 200, 250, 300, 400, 500]
    @zoomLevel = zoomLevels[@zoomLevelIndex]/100
    console.log "zooming here"

    # And apply zoom level to the zoom target (page)
    @$zoomTarget.css
      zoom: "#{@zoomLevel * 100}%"

$ ->
  Newstime.Composer.init()
  return
