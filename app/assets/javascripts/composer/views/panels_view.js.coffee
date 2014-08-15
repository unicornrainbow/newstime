# View layer which manages display and interaction with panels
class @Newstime.PanelsView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'panels-view'
    @panels ?= []

    # Until we have a better means of containg all the application layer, just
    # using this simple means to offset from the top.
    @$el.css top: @topOffset


  attachPanel: (panel) ->
    # Push onto the panels collection.
    @panels.push panel

    # Attach it to the dom el
    @$el.append(panel.el)

  mousedown: (e) ->
    # Received a mousedown event, check for a hit and to see if we need to pass
    # on to a panel.
    console.log e

    return true
