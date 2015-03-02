#= require ../views/menu_title_view

class @Newstime.EditionMenuView extends Newstime.MenuTitleView

  initialize: ->
    @title = 'Edition'
    super

  initializeMenu: ->
    @menuBody.model.set(top: 25)

    @settingsMenuItem = new Newstime.MenuItemView
      title: 'Settings'
      click: ->
        # TODO: Implement Edition > Settings Action
        #

    @printsMenuItem = new Newstime.MenuItemView
      title: 'Prints'
      click: ->
        # TODO: Implement Edition > Prints Action

    @reflowMenuItem = new Newstime.MenuItemView
      title: 'Reflow Text'
      quickKey: '&#x2325;R'
      click: ->
        @composer.reflow()

    @saveMenuItem = new Newstime.MenuItemView
      title: 'Save'
      quickKey: '&#x2325;S'
      click: ->
        @composer.save()

    @menuBody.attachMenuItem(@settingsMenuItem)
    @menuBody.attachMenuItem(@saveMenuItem)
    @menuBody.attachMenuItem(@printsMenuItem)
    @menuBody.attachMenuItem(@reflowMenuItem)
