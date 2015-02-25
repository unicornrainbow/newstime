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
        # Example of updating menu item title.
        #@title = "Enable Snap"
        #@render()

        # TODO: Implement View > Snap Action

    @previewMenuItem = new Newstime.MenuItemView
      title: 'Preview'
      quickKey: '&#x2325;P'
      click: ->
        @composer.launchPreview()

    @menuBody.attachMenuItem(@settingsMenuItem)
    @menuBody.attachMenuItem(@previewMenuItem)
