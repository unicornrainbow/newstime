#= require ./canvas_item_view

class @Newstime.TextAreaView extends Newstime.CanvasItemView

  initialize: (options) ->
    super
    @$el.addClass 'text-area-view'

    @lineHeight = parseInt(Newstime.config.storyTextLineHeight)

    @bind 'paste', @paste
    @bind 'dblclick', @dblclick
    @bind 'resized', @reflow  # Reflow text on resize

    @listenTo @model, 'change:text', @reflow

    @propertiesView = new Newstime.TextAreaPropertiesView(target: this, model: @model)

    @render()

  setElement: (el) ->
    super
    @$el.addClass 'text-area-view'

  render: =>
    super unless @needsReflow

  paste: (e) =>
    # Retreive pasted text. Not cross browser compliant. (Webkit)
    pastedText = e.originalEvent.clipboardData.getData('text/plain')

    @model.set 'text', pastedText

    # Now that we have the desired text, need to save this as the text with the
    # story text-content item, should that be our target. Also need to grab and
    # rerender the contents of the pasted text after it has been reflowed.

    @reflow()

  dblclick: (e) ->
    Newstime.composer.vent.trigger 'edit-text', @model

  keydown: (e) =>
    switch e.keyCode
      when 49 # 1
        unless e.altKey # Don't clash with zoom 1,2,3
          @model.set('columns', 1)
          @reflow()
          e.stopPropagation()
          e.preventDefault()
      when 50 # 2
        unless e.altKey
          @model.set('columns', 2)
          @reflow()
          e.stopPropagation()
          e.preventDefault()
      when 51 # 3
        unless e.altKey
          @model.set('columns', 3)
          @reflow()
          e.stopPropagation()
          e.preventDefault()
      else
        super(e)

  dragBottom: (x, y) ->
    geometry = @getGeometry()
    height = @pageView.snapBottom(y) - geometry.top
    height = Math.floor(height / @lineHeight) * @lineHeight # Snap to Increments of line height
    @model.set
      height: height

  dragBottomLeft: (x, y) ->
    geometry = @getGeometry()
    x = @pageView.snapLeft(x)
    y = @pageView.snapBottom(y)

    height = y - geometry.top
    height = Math.floor(height / @lineHeight) * @lineHeight # Snap to Increments of line height
    @model.set
      left: x
      width: geometry.left - x + geometry.width
      height: height

  dragBottomRight: (x, y) ->
    geometry = @getGeometry()
    width = @pageView.snapRight(x - geometry.left)
    y = @pageView.snapBottom(y)

    height = y - geometry.top
    height = Math.floor(height / @lineHeight) * @lineHeight # Snap to Increments of line height
    @model.set
      width: width
      height: height

  reflow: ->
    # Decide if we are part of a continuation.

    # Get all content items with matching story title
    storyTitle = @model.get('story_title')
    edition = @composer.edition
    contentItems = edition.get('content_items')
    storyContentItems = contentItems.where('story_title': storyTitle)

    # Sort content items based on section, page, y, x
    storyContentItems = storyContentItems.sort (a, b) ->
      if a.section().get('sequence') != b.section().get('sequence')
        a.section().get('sequence') - b.section().get('sequence')
      else if a.page().get('number') != b.page().get('number')
        a.page().get('number') - b.page().get('number')
      else if a.get('top') != b.get('top')
        a.get('top') - b.get('top')
      else
        a.get('left') - b.get('left')

    $.ajax
      method: 'POST'
      url: "#{@composer.edition.url()}/render_text_area.html"
      data:
        composing: true
        content_item: @model.toJSON()
      success: (response) =>
        @$el.html $(response).html()
        @needsReflow = false
        @render()
