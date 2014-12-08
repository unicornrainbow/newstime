class @Newstime.OutlineLayerView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'outline-layer-view'


  attach: (outlineView) ->
    @$el.append(outlineView.el)
