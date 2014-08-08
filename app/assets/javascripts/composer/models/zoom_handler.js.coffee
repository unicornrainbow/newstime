@Newstime = @Newstime || {}

class @Newstime.ZoomHandler extends Backbone.Model

  initialize: (options) ->
    # This will change from platform to platform, but because
    # zoom persist across page referese, need to set it hard.
    # Could possible check client and do mapping that way. (Need good way to
    # detect retina)
    @devicePixelRatio = 2 # window.devicePixelRatio;

    @$body = $('body')
    @$zoomTarget = $('.page')

    @calibrateZoom()
    $(window).resize(@resize)

    #trottledCaptureScrollPosition = _.throttle(@captureScrollPosition, 100)
    $(window).scroll(@captureScrollPosition)


  captureScrollPosition: (e) =>

    #if Newstime.Composer.globalKeyboardDispatch.cmdDown
      #console.log "zooming"
      #return false
    #else

    # Ensure zoom is calibrated
    if window.devicePixelRatio/@devicePixelRatio == @zoomLevel
      # If calibrated, recalulate scroll poisiton
      documentWidth = Math.round(@zoomLevel*document.body.scrollWidth) # scroll width give the correct width, considering auto margins on resize, versus document width
      windowWidth   = Math.round(@zoomLevel*$(window).width())
      scrollLeft   = Math.round(@zoomLevel*$(window).scrollLeft())
      @horizontalScrollPosition = Math.round(100 * scrollLeft / (documentWidth - windowWidth))


    documentHeight = Math.round(@zoomLevel*document.body.scrollHeight)
    windowHeight   = Math.round(@zoomLevel*$(window).height())
    scrollTop   = Math.round(@zoomLevel*$(window).scrollTop())
    @verticalScrollPosition = Math.round(100 * scrollTop / (documentHeight - windowHeight))

  resize: (e) =>
    @calibrateZoom()

  calibrateZoom: ->

    # Calibrate zoom
    @zoomLevel = window.devicePixelRatio/@devicePixelRatio
    @inverseZoomLevel = 1/@zoomLevel

    # Now we negate the zoom level by doing the inverse to the body.
    @$body.css
      zoom: "#{@inverseZoomLevel * 100}%"

    # And apply zoom level to the zoom target (page)
    @$zoomTarget.css
      zoom: "#{@zoomLevel * 100}%"

    # Lock scroll horizontally
    documentWidth = Math.round(@zoomLevel*document.body.scrollWidth) # scroll width give the correct width, considering auto margins on resize, versus document width
    windowWidth   = Math.round(@zoomLevel*$(window).width())
    scrollLeft   = Math.round(@zoomLevel*$(window).scrollLeft())

    if documentWidth - windowWidth == 0
      # Assumed scroll position with no scroll is 50%
      @horizontalScrollPosition = 50
    else
      # Apply scroll position
      scrollLeft = (documentWidth - windowWidth) * (@horizontalScrollPosition/100) / @zoomLevel
      $(window).scrollLeft(scrollLeft)

    # Lock scroll vertically

    documentHeight = Math.round(@zoomLevel*document.body.scrollHeight)
    windowHeight   = Math.round(@zoomLevel*$(window).height())
    scrollTop   = Math.round(@zoomLevel*$(window).scrollTop())

    if documentHeight - windowHeight == 0
      # Assumed scroll position with no scroll is 50%
      @verticalScrollPosition = 50
    else
      # Apply scroll position
      scrollTop = (documentHeight - windowHeight) * (@verticalScrollPosition/100) / @zoomLevel
      $(window).scrollTop(scrollTop)
