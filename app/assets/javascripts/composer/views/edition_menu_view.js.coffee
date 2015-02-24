#= require ../views/menu_title_view

class @Newstime.EditionMenuView extends Newstime.MenuTitleView

  initialize: ->
    @title = 'Edition'
    super

  initializeMenu: ->
    @menuBody.model.set(top: 25)

    @saveMenuItem = new Newstime.MenuItemView(title: 'Save')
    @menuBody.attachMenuItem(@saveMenuItem)
