class @Newstime.MenuTitleView extends Newstime.View

  tagName: 'span'

  initialize: (options) ->
    @$el.addClass "menu-title"

    @title = options.title

    @$el.html(@title)
