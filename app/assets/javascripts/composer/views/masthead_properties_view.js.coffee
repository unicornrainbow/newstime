class @Newstime.MastheadPropertiesView extends Backbone.View
  tagName: 'ul'

  initialize: (options) ->

    @$el.addClass('page-properties')

    @$el.html """
    """

    @listenTo @model, 'change', @render

    @render()


  render: ->
