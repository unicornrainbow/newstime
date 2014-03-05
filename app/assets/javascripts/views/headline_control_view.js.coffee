@Newstime = @Newstime || {}

class @Newstime.HeadlineControlView extends Backbone.View

  events:
    'click': 'click'

  click: ->
    # Scroll offset
    doc = document.documentElement
    body = document.body
    left = (doc && doc.scrollLeft || body && body.scrollLeft || 0)
    top = (doc && doc.scrollTop  || body && body.scrollTop  || 0)

    # Bind to and position the toolbar
    rect = @el.getBoundingClientRect()

    #console.log(, rect.right, rect.bottom, rect.left)
    @toolbar.$el.css(top: rect.top + top, left: rect.right)

  initialize: (options) ->
    @toolbar = options.toolbar
