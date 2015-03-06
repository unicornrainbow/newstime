#= require ../views/menu_title_view

class @Newstime.EditionMenuView extends Newstime.MenuTitleView

  initialize: ->
    @title = 'Edition'
    super

  initializeMenu: ->
    @menuBody.model.set(top: 25)

    @settingsMenuItem = new Newstime.MenuItemView
      title: 'Edition Settings'
      click: ->
        #@composer.toggleEditionSettings()
        url = "http://press.newstime.io/editions/#{Newstime.composer.edition.id}/edit"
        window.open(url, '_blank')

    @printsMenuItem = new Newstime.MenuItemView
      title: 'Prints'
      click: ->
        #@composer.togglePrintsWindow()
        url = "http://press.newstime.io/editions/#{Newstime.composer.edition.id}/prints"
        window.open(url, '_blank')

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
