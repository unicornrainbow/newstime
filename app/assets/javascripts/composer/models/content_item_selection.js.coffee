# TODO: Delete me
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
