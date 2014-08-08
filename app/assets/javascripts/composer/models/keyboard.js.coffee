@Newstime = @Newstime || {}

class @Newstime.Keyboard extends Backbone.Model

  initialize: (options) ->
    @defaultFocus = options.defaultFocus
    $(document).keypress(@keypress)

  keypress: (e) =>
    @defaultFocus.keypress(e)
