class @Newstime.ContentItemSelection
  _.extend @prototype, Backbone.Events

  constructor: (options={}) ->
    @contentItem = options.contentItem
    @contentItemView = options.contentItemView

  getPropertiesView: ->
    @contentItemView.getPropertiesView()

  deactivate: ->
    @contentItemView.deactivate()

  destroy: ->

  convertToMultiSelection: ->
    multiSelection = new Newstime.MultiSelection()
    multiSelection.add(@contentItem)
    multiSelection
