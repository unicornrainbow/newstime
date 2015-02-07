#= require ../views/panel_view
#
class @Newstime.PagesPanelView extends @Newstime.PanelView

  initializePanel: ->
    @model.set(width: 200, height: 200)

  renderPanel: ->
