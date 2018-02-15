@Dreamtool = @Dreamtool or {}

class @Dreamtool.MobileTextEditorView extends @Newstime.View

  initialize: ->

    @$el.addClass 'mobile-text-editor-view'

    @$el.html """
      <textarea></textarea>
    """

  # slideIn: ->
  #
  # slideOut: ->
