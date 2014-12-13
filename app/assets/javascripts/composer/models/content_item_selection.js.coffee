class @Newstime.ContentItemSelection
  _.extend @prototype, Backbone.Events

  constructor: (options={}) ->
    @contentItem = options.contentItem
    @contentItemView = options.contentItemView

    @bind 'mousedown', @mousedown
    @bind 'keydown', @keydown

  getPropertiesView: ->
    @contentItemView.getPropertiesView()

  hit: (x, y) ->
    @contentItemView.hit(x, y)

  deactivate: ->
    @contentItemView.deactivate()

  mousedown: (e) ->
    @contentItemView.trigger 'mousedown', e

  keydown: (e) ->
    @contentItemView.trigger 'keydown', e
