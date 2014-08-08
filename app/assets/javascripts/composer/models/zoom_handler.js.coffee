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

    @resize()
    $(window).resize(@resize)


  resize: (e) =>
    # Calibrate zoom
    zoomLevel = window.devicePixelRatio/@devicePixelRatio * 100
    inverseZoomLevel = 10000/zoomLevel

    # Now we negate the zoom level by doing the inverse to the body.
    @$body.css
      zoom: "#{inverseZoomLevel}%"

    # And apply zoom level to the zoom target (page)
    @$zoomTarget.css
      zoom: "#{zoomLevel}%"
