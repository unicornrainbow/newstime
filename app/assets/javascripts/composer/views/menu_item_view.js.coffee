class @Newstime.MenuItemView extends Newstime.View

  initialize: (options) ->
    @$el.addClass 'menu-item'
    @title ?= options.title

    @$el.html @title

    @boundry = new Newstime.Boundry

    @updateBoundry()

    @bindUIEvents()

  updateBoundry: ->
    offset = @$el.position()

    @boundry.top = offset.top
    @boundry.left = offset.left
    @boundry.width = @$el.width()
    @boundry.height = @$el.height()


  mouseover: (e) ->
    @$el.addClass 'hover'

  mouseout: (e) ->
    @$el.removeClass 'hover'
