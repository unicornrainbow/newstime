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


  dragBottomRight: (x, y) ->
    aspectRatio = @model.get('aspect_ratio') # (width/height)

    @composer.clearVerticalSnapLines()
    geometry  = @getGeometry()
    snapRight = @pageView.snapRight(x)
    y         = @pageView.snapBottom(y)

    if snapRight
      @composer.drawVerticalSnapLine(snapRight)
      width = snapRight - geometry.left
    else
      width     = x - geometry.left

    height = y - geometry.top

    # Select the largest value with respect to aspect ratio
    #if height * aspectRatio > width
      ## Height is dominant
      #width = height * aspectRatio
    #else
      ## Width is dominant
      #height = width / aspectRatio


    height = width / aspectRatio

    @model.set
      width: width
      height: height
