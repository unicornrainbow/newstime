class @Newstime.MenuItemView extends Newstime.View

  initialize: (options) ->
    @$el.addClass 'menu-item'
    @title ?= options.title

    @$el.html @title
