@Newstime = @Newstime || {}

class @Newstime.StoryTextControlView extends Backbone.View

  events:
    'click': 'click'

  click: ->
    @toolPalette.setStoryTextControl(this)

  initialize: (options) ->
    @toolPalette = options.toolPalette
