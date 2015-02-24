class @Newstime.MenuBodyView extends Newstime.View

  initialize: (options) ->
    @$el.addClass "menu-body"

    @composer = Newstime.composer

    @$el.html """
      Menu Body
    """

  open: ->

  close: ->
