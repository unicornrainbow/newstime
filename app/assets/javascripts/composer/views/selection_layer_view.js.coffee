class @Newstime.SelectionLayerView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'selection-layer-view'

  setSelection: (selection) ->
    @currentSelection = selection

    selectionView = new Newstime.SelectionView
      selection: selection

    @$el.empty()
    @$el.append selectionView.el
