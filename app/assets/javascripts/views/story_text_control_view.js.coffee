@Newstime = @Newstime || {}

class @Newstime.StoryTextControlView extends Backbone.View

  events:
    'click': 'click'

  click: ->
    @tool_palette.setHeadlineControl(this)

  initialize: (options) ->
    @tool_palette = options.tool_palette
