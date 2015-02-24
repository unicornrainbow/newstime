#= require ../views/menu_title_view

class @Newstime.SectionMenuView extends Newstime.MenuTitleView

  initialize: ->
    @title = 'Section'
    super

  initializeMenu: ->
    @menuBody.model.set(top: 25)
