@Newstime = @Newstime || {}

class @Newstime.ContentRegionPropertiesView extends Backbone.View

  initialize: ->
    @$el.hide()
    @$el.addClass('content-region-properties')

    @$el.html """
      <div class="title-bar">
        Content Region
        <span class="dismiss"></span>
      </div>
      <div class="palette-body">
      </div>
    """

    @$columnsSelect = @$el.find('.story-content-item-columns')
    @$heightInput = @$el.find('.story-content-item-height')

  setContentRegionControl: (targetControl) ->
    # Scroll offset
    doc = document.documentElement
    body = document.body
    left = (doc && doc.scrollLeft || body && body.scrollLeft || 0)
    top = (doc && doc.scrollTop  || body && body.scrollTop  || 0)

    # Bind to and position the tool-palette
    rect = targetControl.el.getBoundingClientRect()
    @$el.css(top: rect.top + top, left: rect.right)

    # Initialize Values
    #@$storyText = targetControl.$el
    #@storyTextId = @$storyText.data('story-text-id')

    # Request values from the backend.
    #$.ajax
      #type: "GET"
      #url: "/content_items/#{@storyTextId}.json"
      #data:
        #authenticity_token: Newstime.Composer.authenticityToken
      #success: (data) =>
        #@$columnsSelect.val(data['columns'])
        #@$heightInput.val(data['height'])

    @$el.show()
