@Newstime = @Newstime || {}

class @Newstime.GlobalKeyboardDispatch extends Backbone.Model

  initialize: (options) ->
    @composer = options.composer

    @optDown = false

    $(window).blur ->
      #console.log "canceled"
      @optDown = false
      window.onmousewheel = null

  keypress: (e) ->
    switch e.charCode
      when 116 # t
        # Toggle grid (State should persist across reloads, this is workspace
        # and should be user specific.
        Newstime.Composer.toggleGridOverlay()
      #else
        #console.log e

  keydown: (e) ->
    switch e.keyCode
      when 18 # opt
        @optDown = true

        zoomMouseWheel = (e) =>
          if e.wheelDeltaY < 0
            @composer.zoomInPoint(e.x, e.y)
          else if e.wheelDeltaY > 0
            @composer.zoomOut()

        zoomMouseWheel = _.throttle(zoomMouseWheel, 100)

        window.onmousewheel = (e) ->
          e.preventDefault()
          zoomMouseWheel(e)

      when 187 # +
        if e.altKey
          @composer.zoomIn()

      when 189 # -
        if e.altKey
          @composer.zoomOut()

      when 48 # 0
        if e.altKey
          @composer.zoomReset()

      when 32 # space
        e.stopPropagation()
        e.preventDefault()
        #console.log "handle grab tool"

        # Engage Drag Mode.
        @trigger 'dragModeEngaged'


  keyup: (e) ->
    #console.log "up", e.keyCode
    switch e.keyCode
      when 18 # opt
        @optDown = false
        window.onmousewheel = null

      when 32 #space
        e.stopPropagation()
        e.preventDefault()
        @trigger 'dragModeDisengaged'