@Newstime = @Newstime || {}

class @Newstime.PageComposeView extends Backbone.View

  events:
    'click': 'click'

  #initialize: (options) ->

  click: ->
    alert "Hello"
