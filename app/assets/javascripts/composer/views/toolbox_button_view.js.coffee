@Newstime = @Newstime || {}

class @Newstime.ToolboxButtonView extends Backbone.View
  initialize: (options) ->
    @type = options.type

    @$el.addClass "toolbox-button"
    @$el.addClass @type
