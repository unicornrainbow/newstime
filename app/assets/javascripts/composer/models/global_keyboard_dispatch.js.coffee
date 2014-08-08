@Newstime = @Newstime || {}

class @Newstime.GlobalKeyboardDispatch extends Backbone.Model

  initialize: ->
    console.log "Gobal Keyboard Dispatch"

  keypress: (e) ->
    switch e.charCode
      when 116 # t
        # Toggle grid (State should persist across reloads, this is workspace
        # and should be user specific.
        Newstime.Composer.toggleGridOverlay()

      else
        console.log e
