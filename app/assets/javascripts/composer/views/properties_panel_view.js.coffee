#= require ../views/panel_view

class @Newstime.PropertiesPanelView extends @Newstime.PanelView

  initializePanel: ->
    @$el.addClass('newstime-properties-panel')

  mount: (propertiesView) ->
    if propertiesView
      @$body.html propertiesView.el
    else
      @clear()
