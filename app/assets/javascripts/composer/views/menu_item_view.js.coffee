class @Newstime.MenuItemView extends Newstime.View

  initialize: (options) ->
    @$el.addClass 'menu-item'
    @title ?= options.title

    @quickKey ?= options.quickKey

    @clickCallback = options.click

    @composer = Newstime.composer

    @render()

    @boundry = new Newstime.Boundry

    @updateBoundry()

    @bindUIEvents()

  render: ->
    @$el.html @title

    if @quickKey
      @$el.append """
         <span class="quick-key">#{@quickKey}</span>
      """

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

  mousedown: (e) ->
    @composer.selectedMenu.close()
    @clickCallback() if @clickCallback
