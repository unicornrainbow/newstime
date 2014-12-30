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
    storyTitle = @model.get('story_title')

    # Get all content items with matching story title
    edition = @composer.edition
    contentItems = edition.get('content_items')
    storyContentItems = contentItems.where('story_title': storyTitle)

    # Sort content items based on section, page, y, x
    storyContentItems = storyContentItems.sort (a, b) ->
      if a.getSection().get('sequence') != b.getSection().get('sequence')
        a.getSection().get('sequence') - b.getSection().get('sequence')
      else if a.getPage().get('number') != b.getPage().get('number')
        a.getPage().get('number') - b.getPage().get('number')
      else if a.get('top') != b.get('top')
        a.get('top') - b.get('top')
      else
        a.get('left') - b.get('left')

    # Now we have the linked text area, so we can reflow the relevent content.
    # We need to indicate a parent in the reflow, which will be used in place of
    # the input text on the server end. It will use overflow, and run with the
    # current parameters.
    #
    # We need to up date this and everyflowwing text area that changes and
    # occurs on this section. We can get corrisponding views.
    #
    # We should have a reorder method, that will happen when we need to read the
    # order again.
    #
    # This way, we just all reflow, and the one that follows, and it will do the
    # same, and then the will all be called.





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
