class @Newstime.CanvasLayerView extends Backbone.View

  initialize: (options) ->
    @composer = options.composer

    # Capture Elements
    @$window = $(window)
    @$document = $(document)
    @$body = $('body')

    @zoomLevels = [100, 110, 125, 150, 175, 200, 250, 300, 400, 500]

    # Capture and Init pages
    @pages = []
    $("[page-compose]", @$el).each (i, el) =>
      @pages.push new Newstime.PageComposeView(
        el: el
        coverLayerView: this
      )
    #console.log @pages

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


    # For testing, draw a box that follows the cursor on the canvas layer.
    @$trackingBox.css(top: "#{y-150}px", left: "#{x-150}px")

    console.log x, y

    # This method is called, telling me where on the canvas layer the mouse is
    # hovering.
    # This is an exact pixel location, relative to the 0,0 location in the top
    # right of the canvas layer. When something is zoomed in, we will need to
    # reduce these down the the actually pixels. That should be fine. So, we
    # need to apply zoom, and make sure offsets are considered, then we should
    # be able to simply detect againt the array of pages.
    #
    # The mouse will be at a certian corrdinate from the CoverLayer, the
    # composer should do the mapping, and pass the value into here that
    # corrilates with where it should be registered on the canvas view layer,
    # without the zoom applied. Zoom should be ignored from a programtic point
    # of view, it is for display on.
    #
    #
    #





    #page = _.find @pages, (page) =>
      #@detectHit page, x, y

    #return page

  detectHit: (page, x, y) ->

    # TODO: Implement

    # TODO: This is where scroll offset and zoom is going to come into play.

    # Get panel geometry
    #geometry = page.geometry()
    #console.log geometry

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


      $(window).scrollLeft(scrollLeft)

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
      @$window.scrollLeft(scrollLeft)

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
