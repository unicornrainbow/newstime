class @Newstime.SelectionLayerView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'selection-layer-view'

    @composer = options.composer

    @composer.bind 'zoom', @zoom, this


  zoom: ->
    @zoomLevel = @composer.zoomLevel
    console.log @zoomLevel


  setSelection: (selection) ->
    @currentSelection = selection

    selectionView = new Newstime.SelectionView
      selection: selection

    @$el.empty()
    @$el.append selectionView.el
