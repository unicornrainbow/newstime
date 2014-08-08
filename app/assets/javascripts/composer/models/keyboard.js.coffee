@Newstime = @Newstime || {}

class @Newstime.Keyboard extends Backbone.Model

  initialize: (options) ->
    @defaultFocus = options.defaultFocus
    $(document).keypress(@keypress)
    $(document).keydown(@keydown)
    $(document).keyup(@keyup)

  keypress: (e) =>
    @defaultFocus.keypress(e)

  keydown: (e) =>
    @defaultFocus.keydown(e)

  keyup: (e) =>
    @defaultFocus.keyup(e)
