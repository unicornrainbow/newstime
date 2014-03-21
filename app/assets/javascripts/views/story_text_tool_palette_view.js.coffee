@Newstime = @Newstime || {}

# TODO: Create a Palette Abstraction

class @Newstime.StoryTextToolPaletteView extends Backbone.View

  events:
   'mousedown .title-bar': 'beginDrag'
   'mouseup .title-bar': 'endDrag'
   'click .dismiss': 'dismiss'
   'click .story-delete': 'delete'

  delete: ->
    if confirm 'Click OK to delete story'
      $.ajax
        type: "DELETE"
        url: "/content_items/#{@storyTextId}.json"
        data:
          authenticity_token: Newstime.Composer.authenticityToken
        complete: =>
          # Delete the node and hide palette
          @$storyText.remove()
          @$el.hide()

  dismiss: ->
    @save()
    @$el.hide()

  save: ->
    $.ajax
      type: "PUT"
      url: "/content_items/#{@storyTextId}.json"
      data:
        authenticity_token: Newstime.Composer.authenticityToken
        content_item:
          columns: @$columnsSelect.val()
          height: @$heightInput.val()

  moveHandeler: (e) =>
    @$el.css('top', event.pageY + @topMouseOffset)
    @$el.css('left', event.pageX + @leftMouseOffset)

  beginDrag: (e) ->
    # Calulate offsets
    @topMouseOffset = parseInt(@$el.css('top')) - event.pageY
    @leftMouseOffset = parseInt(@$el.css('left')) - event.pageX

    $(document).bind('mousemove', @moveHandeler)

  endDrag: (e) ->
    $(document).unbind('mousemove', @moveHandeler)

  initialize: ->
    @$el.hide()
    @$el.addClass('story-text-tool-palette')

    @$el.html """
      <div class="title-bar">
        Story
        <span class="dismiss"></span>
      </div>
      <div class="palette-body">
        <div>
          <select class="story-content-item-columns">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
          </select>
        </div>
        <br>
        Height:
        <input class="nt-control story-content-item-height"></input>
        <br>
        <a class="story-delete">Delete</a>
      </div>
    """

    @$columnsSelect = @$el.find('.story-content-item-columns')
    @$heightInput = @$el.find('.story-content-item-height')

  setStoryTextControl: (targetControl) ->
    # Scroll offset
    doc = document.documentElement
    body = document.body
    left = (doc && doc.scrollLeft || body && body.scrollLeft || 0)
    top = (doc && doc.scrollTop  || body && body.scrollTop  || 0)

    # Bind to and position the tool-palette
    rect = targetControl.el.getBoundingClientRect()
    @$el.css(top: rect.top + top, left: rect.right)

    # Initialize Values
    @$storyText = targetControl.$el
    @storyTextId = @$storyText.data('story-text-id')

    # Request values from the backend.
    $.ajax
      type: "GET"
      url: "/content_items/#{@storyTextId}.json"
      data:
        authenticity_token: Newstime.Composer.authenticityToken
      success: (data) =>
        @$columnsSelect.val(data['columns'])
        @$heightInput.val(data['height'])

    @$el.show()
