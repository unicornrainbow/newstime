class @Newstime.CanvasLayerView extends Backbone.View

  initialize: (options) ->
    @composer = options.composer
    @topOffset = options.topOffset

    # Capture Elements
    @$window = $(window)
    @$document = $(document)
    @$body = $('body')

    #@zoomLevels = [25, 33, 50, 67, 75, 90, 100, 110, 125, 150, 175, 200, 250, 300, 400, 500]
    @zoomLevels = [100, 110, 125, 150, 175, 200, 250, 300, 400, 500]

    # Measure and set eaxct width (Needed for getting exact locations when
    # zooming.
    #@$el.css(width: @$el.width())

    # Capture and Init pages
    @pages = []
    $("[page-compose]", @$el).each (i, el) =>
      @pages.push new Newstime.PageComposeView(
        el: el
        canvasLayerView: this
      )

    _.each @pages, (page) =>
      page.bind 'tracking', @tracking, this
      page.bind 'tracking-release', @trackingRelease, this

    @bind 'mouseover',  @mouseover
    @bind 'mouseout',   @mouseout
    @bind 'mousedown',  @mousedown
    @bind 'mouseup',    @mouseup
    @bind 'mousemove',  @mousemove


  tracking: (page) ->
    @trackingPage = page
    @trigger 'tracking', this

  trackingRelease: (page) ->
    @trackingPage = null
    @trigger 'tracking-release', this

  hit: (x, y) ->
    e = { x: x, y: y }
    @adjustEventXY(e)

    page = _.find @pages, (page) =>
      @detectHit page, e.x, e.y

    if @hovered # Only process events if hovered.
      if page
        if @hoveredObject != page
          if @hoveredObject
            @hoveredObject.trigger 'mouseout', e
          @hoveredObject = page
          @hoveredObject.trigger 'mouseover', e

        return true
      else
        if @hoveredObject
          @hoveredObject.trigger 'mouseout', e
          @hoveredObject = null

        return false

    else
      # Defer processing of events until we are declared the hovered object.
      @hoveredObject = page
      return true


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

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e


  mouseout: (e) ->
    @hovered = false

    @adjustEventXY(e)

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e
      @hoveredObject = null

  mousedown: (e) ->
    @adjustEventXY(e)

    if @hoveredObject
      @hoveredObject.trigger 'mousedown', e


  mouseup: (e) ->
    @adjustEventXY(e)

    if @trackingPage
      @trackingPage.trigger 'mouseup', e
      return true


  mousemove: (e) ->
    @adjustEventXY(e)

    if @trackingPage
      @trackingPage.trigger 'mousemove', e
      return true

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
    #@zoomLevelIndex = 6
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
    #console.log "zooming here"

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
