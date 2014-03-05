@Newstime = @Newstime || {}

class @Newstime.HeadlineControlView extends Backbone.View

  events:
    'click': 'click'

  click: ->
    @toolbar.setHeadlineControl(this)

  initialize: (options) ->
    @toolbar = options.toolbar
