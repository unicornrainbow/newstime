@Newstime = @Newstime || {}

class @Newstime.GlobalKeyboardDispatch extends Backbone.Model

  initialize: ->
    console.log "Gobal Keyboard Dispatch"

    @cmdDown = false

    $(window).blur ->
      console.log "canceled"
      @cmdDown = false
      window.onmousewheel = null


  keypress: (e) ->
    switch e.charCode
      when 116 # t
        # Toggle grid (State should persist across reloads, this is workspace
        # and should be user specific.
        Newstime.Composer.toggleGridOverlay()
      else
        console.log e

  keydown: (e) ->
    switch e.keyCode
      when 91 # cmd
        @cmdDown = true

        zoomMouseWheel = (e) ->
          console.log "zooming"
          console.log(e)

        zoomMouseWheel = _.throttle(zoomMouseWheel, 200)

        window.onmousewheel = (e) ->
          e.preventDefault()
          zoomMouseWheel(e)

  keyup: (e) ->
    console.log "up", e.keyCode
    switch e.keyCode
      when 91 # cmd
        @cmdDown = false
        window.onmousewheel = null
