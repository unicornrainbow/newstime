class @Newstime.ContentItemSelection
  _.extend @prototype, Backbone.Events

  constructor: (options={}) ->
    @contentItem = options.contentItem
    @contentItemView = options.contentItemView

  getPropertiesView: ->
    @contentItemView.getPropertiesView()

  hit: (x, y) ->
    @contentItemView.hit(x, y)

  deactivate: ->
    @contentItemView.deactivate()
