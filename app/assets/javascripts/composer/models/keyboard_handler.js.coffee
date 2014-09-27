@Newstime = @Newstime || {}

class @Newstime.KeyboardHandler extends Backbone.Model

  initialize: (options) ->
    @composer = options.composer

    $(document).keypress(@keypress)
    $(document).keydown(@keydown)
    $(document).keyup(@keyup)

    @optDown = false

    $(window).blur ->
      #console.log "canceled"
      @optDown = false
      window.onmousewheel = null

  keypress: (e) =>
    return unless @composer.hasFocus # Ignore unless composer has focus

    switch e.charCode
      when 116 # t
        # Toggle grid (State should persist across reloads, this is workspace
        # and should be user specific.
        Newstime.Composer.toggleGridOverlay()
      #else
        #console.log e

  keydown: (e) =>
    return unless @composer.hasFocus # Ignore unless composer has focus

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

      when 83 # s
        if e.ctrlKey # ctrl+s
          edition.save() # Save edition

      #when 8 # del
        #e.stopPropagation()
        #e.preventDefault()


  keyup: (e) =>
    return unless @composer.hasFocus # Ignore unless composer has focus

    #console.log "up", e.keyCode
    switch e.keyCode

      when 18 # opt
        @optDown = false
        window.onmousewheel = null

      when 32 #space
        e.stopPropagation()
        e.preventDefault()
        @trigger 'dragModeDisengaged'
