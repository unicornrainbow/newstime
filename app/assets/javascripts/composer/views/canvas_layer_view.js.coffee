class @Newstime.CanvasLayerView extends Backbone.View

  initialize: (options) ->
    @composer = options.composer

    # Capture Elements
    @$window = $(window)
    @$document = $(document)
    @$body = $('body')

    @zoomLevels = [100, 110, 125, 150, 175, 200, 250, 300, 400, 500]

    # Measure and set eaxct width (Needed for getting exact locations when
    # zooming.
    #@$el.css(width: @$el.width())

    # Capture and Init pages
    @pages = []
    $("[page-compose]", @$el).each (i, el) =>
      @pages.push new Newstime.PageComposeView(
        el: el
        coverLayerView: this
      )

    @$trackingBox = $("<div class='tracking-box'></div>")
    @$el.append @$trackingBox[0]

  hit: (x, y) ->

    # Apply scroll offset
    x += $(window).scrollLeft()
    y += $(window).scrollTop()

    # Apply zoom
    if @zoomLevel
      x = Math.round(x/@zoomLevel)
      y = Math.round(y/@zoomLevel)

    # Now that we have the relative corrdinates, we need to match against the
    # corrdinates of the pages, which should be ignorant of zoom, and relative
    # to the 0,0 point of the canvas layer.

    page = _.find @pages, (page) =>
      @detectHit page, x, y

    return page

  detectHit: (page, x, y) ->

    # We need to know where the element is relative to the canvas, but can not
    # rely on relative position between elements.
    #
    # We will therefore need position relative to the document.
    #
    # Applying zoom if nessecary
    #
    # Applying scroll if needed, but certianly won't be.
    #
    # Will need to be recaluated, each time, or at specific events, to ensure
    # accroacy.

    # Get panel geometry
    #console.log @zoomLevel, $(window).scrollLeft()
    #console.log $(window).scrollLeft()/@zoomLevel

    if @zoomLevel
      xCorrection = Math.round(($(window).scrollLeft()/@zoomLevel) * (@zoomLevel - 1))
    else
      xCorrection = 0

    #console.log Math.round(($(window).scrollLeft()/@zoomLevel) * (@zoomLevel - 1))

    geometry = page.geometry()
    geometry.x -= xCorrection

    #if @zoomLevel
      #console.log Math.round($(window).scrollLeft())
      #console.log @zoomLevel
      ##geometry.x -= $(window).scrollLeft() / @zoomLevel
    #else
      #geometry.x -= $(window).scrollLeft()

    console.log geometry

    ## Adjust for top offset, which currently isn't considered in panel gemotry
    ## (but should be)
    #geometry.y = geometry.y - @topOffset

    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    #buffer = 4 # 2px
    #geometry.x -= buffer
    #geometry.y -= buffer
    #geometry.width += buffer*2
    #geometry.height += buffer*2

    ## Detect if corrds lie within the geometry
    #if x >= geometry.x && x <= geometry.x + geometry.width
      #if y >= geometry.y && y <= geometry.y + geometry.height
        #return true

    #return false


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
    @$el.css
      zoom: "#{@zoomLevel * 100}%"

    @repositionScroll()


  zoomInPoint: (x, y) ->
    # This is a demo implementation, just to test the idea
    @zoomLevelIndex ?= 0
    @zoomLevelIndex = Math.min(@zoomLevelIndex+1, 10)
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100

    # And apply zoom level to the zoom target (page)
    @$el.css
      zoom: "#{@zoomLevel * 100}%"

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
    @$el.css
      zoom: "#{@zoomLevel * 100}%"

    @repositionScroll()

  zoomReset: ->
    @zoomLevelIndex = 0
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100

    # And apply zoom level to the zoom target (page)
    @$el.css
      zoom: "#{@zoomLevel * 100}%"

    @repositionScroll()

  zoomToPoint: (x, y) ->
    # This is a demo implementation, just to test the idea

    @zoomLevelIndex ?= 0
    @zoomLevelIndex = @zoomLevelIndex+1
    @zoomLevel = @zoomLevels[@zoomLevelIndex]/100
    console.log "zooming here"

    # And apply zoom level to the zoom target (page)
    @$el.css
      zoom: "#{@zoomLevel * 100}%"


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
