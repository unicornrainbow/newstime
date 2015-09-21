#= require ./content_item_view
#
# Description: The video view which appears on the canvas area. Allows videos to
#              be drawn, resized and positioned.
#
class @Newstime.VideoView extends @Newstime.ContentItemView

  contentItemClassName: 'video-view'

  initializeContentItem: ->
    console.log @$el
    #@setContentEl(options.contentEl) if options.contentEl
    #@modelChanged()

  @getter 'uiLabel', -> "Video"


  _createPropertiesView: ->
    new Newstime.VideoPropertiesView(target: this, model: @model).render()

  _createModel: ->
    @edition.contentItems.add({_type: 'VideoContentItem'})
