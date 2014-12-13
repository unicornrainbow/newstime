class @Newstime.OutlineLayerView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'outline-layer-view'

    @outlineViews = []

    @composer = options.composer

    @composer.bind 'zoom', @zoom, this


  zoom: ->
    @zoomLevel = @composer.zoomLevel

    # Recalulate a position the containing div.
    #
    # Render all outline views.


  attach: (outlineView) ->
    @outlineViews.push(outlineView)
    @$el.append(outlineView.el)
