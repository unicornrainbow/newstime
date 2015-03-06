#= require ../views/menu_title_view

class @Newstime.ViewMenuView extends Newstime.MenuTitleView

  initialize: ->
    @title = 'View'
    super

  initializeMenu: ->
    @menuBody.model.set(top: 25)

    @snapMenuItem = new Newstime.MenuItemView
      title: 'Disable Snap'
      hidden: true
      click: ->
        if @composer.snapEnabled
          @title = "Enable Snap"
          @render()
          @composer.disableSnap()
        else
          @title = "Disable Snap"
          @render()
          @composer.enableSnap()

        # Example of updating menu item title.
        #@title = "Enable Snap"
        #@render()

        # TODO: Implement View > Snap Action


    @panelsMenuItem = new Newstime.MenuItemView
      title: 'Hide Panels'
      quickKey: 'P'
      click: ->
        @composer.togglePanelLayer()


    @menuBody.attachMenuItem(@snapMenuItem)
    @menuBody.attachMenuItem(@panelsMenuItem)
