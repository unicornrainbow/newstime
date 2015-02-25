#= require ../views/menu_title_view

class @Newstime.ViewMenuView extends Newstime.MenuTitleView

  initialize: ->
    @title = 'View'
    super

  initializeMenu: ->
    @menuBody.model.set(top: 25)

    @settingsMenuItem = new Newstime.MenuItemView
      title: 'Snap'
      click: ->
        @title = "Enable Snap"
        @render()

        console.log "Snap clicked"

    @menuBody.attachMenuItem(@settingsMenuItem)
