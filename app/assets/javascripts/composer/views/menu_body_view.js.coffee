class @Newstime.MenuBodyView extends Newstime.View

  initialize: (options) ->
    @$el.addClass "menu-body"

    @composer = Newstime.composer

    @$el.hide()

    @model = new Backbone.Model()

    @attachedMenuItem = []

    @composer = Newstime.composer

    @boundry = new Newstime.Boundry()

    @listenTo @model, 'change', @render
    @listenTo @model, 'change', @updateBoundry
    @render()

  render: ->
    @$el.css @model.pick 'top', 'left'

  updateBoundry: ->
    _.extend @boundry, @model.pick 'top', 'left'
    @boundry.width = @$el.width()
    @boundry.height = @$el.height()

  open: ->
    @$el.show()
    @updateBoundry()
    @composer.menuLayerView.cutout.addBoundry(@boundry)

  close: ->
    @$el.hide()
    @composer.menuLayerView.cutout.removeBoundry(@boundry)

  attachMenuItem: (menuItemView) ->
    @attachedMenuItem.push(menuItemView)
    @$el.append(menuItemView.el)
