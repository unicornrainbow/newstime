
class @Newstime.StatusIndicatorView extends Backbone.View # Would be better named status indicator and use it to tell about save progress

  initialize: (options) ->
    @$el.addClass 'status-indicator'
    @hide()

  unsavedChanged: (val) ->
    @$el.toggleClass 'unsaved-changes', val
    @show()

  showMessage: (msg, hideAfter) ->
    if @hideAfterTimeout
      clearTimeout(@hideAfterTimeout)
      @hideAfterTimeout = null

    @$el.html msg
    if msg?
      @show()
    else
      @hide()

    if hideAfter
      @hideAfterTimeout = @clear
      setTimeout @clear, hideAfter

  clear: =>
    @hideAfterTimeout = null
    @hide()


  show: ->
    @$el.removeClass 'fade-out'

  hide: ->
    @$el.addClass 'fade-out'
