#= require ../views/menu_title_view

class @Newstime.EditionMenuView extends Newstime.MenuTitleView

  initialize: ->
    @title = 'Edition'
    super

  initializeMenu: ->
    @menuBody.model.set(top: 25, left: 100)
