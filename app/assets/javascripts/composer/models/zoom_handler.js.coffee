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
    $(window).scroll(@captureScrollPosition)


  captureScrollPosition: (e) =>

    # Ensure zoom is calibrated
    if window.devicePixelRatio/@devicePixelRatio == @zoomLevel
      # If calibrated, recalulate scroll poisiton
      documentWidth = Math.round(@zoomLevel*document.body.scrollWidth) # scroll width give the correct width, considering auto margins on resize, versus document width
      windowWidth   = Math.round(@zoomLevel*$(window).width())
      scrollLeft   = Math.round(@zoomLevel*$(window).scrollLeft())
      @horizontalScrollPosition = Math.round(100 * scrollLeft / (documentWidth - windowWidth))

  resize: (e) =>
    @calibrateZoom()

  calibrateZoom: ->
    console.log "calibrating zoom"

    # Calibrate zoom
    @zoomLevel = window.devicePixelRatio/@devicePixelRatio
    @inverseZoomLevel = 1/@zoomLevel

    # Now we negate the zoom level by doing the inverse to the body.
    @$body.css
      zoom: "#{@inverseZoomLevel * 100}%"

    # And apply zoom level to the zoom target (page)
    @$zoomTarget.css
      zoom: "#{@zoomLevel * 100}%"

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

    console.log
      zoomLevel: @zoomLevel
      windowWidth: windowWidth
      documentWidth: documentWidth
      scrollLeft: scrollLeft
      horizontalScrollPosition: @horizontalScrollPosition
