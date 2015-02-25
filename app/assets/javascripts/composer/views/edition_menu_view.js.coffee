#= require ../views/menu_title_view

class @Newstime.EditionMenuView extends Newstime.MenuTitleView

  initialize: ->
    @title = 'Edition'
    super

  initializeMenu: ->
    @menuBody.model.set(top: 25)

    @saveMenuItem = new Newstime.MenuItemView
      title: 'Save'
      click: ->
        @composer.save()

    @settingsMenuItem = new Newstime.MenuItemView
      title: 'Settings'
      click: ->
        console.log "Show edition settings"


    @menuBody.attachMenuItem(@saveMenuItem)
    @menuBody.attachMenuItem(@settingsMenuItem)
