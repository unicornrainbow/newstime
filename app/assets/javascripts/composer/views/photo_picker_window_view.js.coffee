#= require ../views/window_view

class @Newstime.PhotoPickerWindowView extends @Newstime.WindowView

  initializeWindow: ->
    @$el.addClass 'photo-picker-window-view'
    @model.set
      width: 700
      height: 500

    # Attach photo picker view into body
    @photoPickerView = new Newstime.PhotoPickerView(window: this)
    @$body.html @photoPickerView.el

  # Prompt user to select photo.
  #
  # respondToView - PhotoView to respond to when photo selected.
  selectPhoto: (respondToView) ->
    @respondToView = respondToView
    @show()
