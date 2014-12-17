class @Newstime.ContentItemSelection
  _.extend @prototype, Backbone.Events

  constructor: (options={}) ->
    @contentItem = options.contentItem
    @contentItemView = options.contentItemView

    @bind 'mousedown', @mousedown
    @bind 'mouseover', @mouseover
    @bind 'mouseout', @mouseout
    @bind 'keydown',   @keydown
    @bind 'dblclick',  @dblclick

  getPropertiesView: ->
    @contentItemView.getPropertiesView()

  hit: (x, y) ->
    @contentItemView.hit(x, y)

  deactivate: ->
    @contentItemView.deactivate()

  mousedown: (e) ->
    @contentItemView.trigger 'mousedown', e

  mouseover: (e) ->
    @contentItemView.trigger 'mouseover', e

  mouseout: (e) ->
    @contentItemView.trigger 'mouseout', e

  keydown: (e) ->
    @contentItemView.trigger 'keydown', e

  dblclick: (e) ->
    @contentItemView.trigger 'dblclick', e
