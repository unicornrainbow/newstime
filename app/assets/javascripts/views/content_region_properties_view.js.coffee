@Newstime = @Newstime || {}

class @Newstime.ContentRegionPropertiesView extends Backbone.View

  events:
    'click .content-region-delete': 'delete'

  initialize: ->
    @palette = new Newstime.PaletteView(title: "Content Region")
    @palette.attach(@$el)

    @$el.html """
      Width: Dropdown
      <br>
      <a class="content-region-delete">Delete</a>
    """

    @$el.addClass('content-region-properties')

    @$columnsSelect = @$el.find('.story-content-item-columns')
    @$heightInput = @$el.find('.story-content-item-height')

  setPosition: (top, left) ->
    # Scroll offset
    doc = document.documentElement
    body = document.body
    leftOffset = (doc && doc.scrollLeft || body && body.scrollLeft || 0)
    topOffset = (doc && doc.scrollTop  || body && body.scrollTop  || 0)

    # If greater than a certain distance to the right, subtract the width to
    # counter act.

    if leftOffset + left > 1000
      left = left - @palette.width()

    @palette.setPosition(topOffset + top, leftOffset + left)

  delete: ->
    if confirm 'Click OK to delete content region'
      $.ajax
        type: "DELETE"
        url: "/content_regions/#{@contentRegionId}.json"
        data:
          authenticity_token: Newstime.Composer.authenticityToken
        complete: =>
          # Delete the node and hide palette
          @$contentRegionControl.remove()
          @palette.hide()

  show: ->
    @palette.show()

  setContentRegionControl: (targetControl) ->
    # Scroll offset
    doc = document.documentElement
    body = document.body
    left = (doc && doc.scrollLeft || body && body.scrollLeft || 0)
    top = (doc && doc.scrollTop  || body && body.scrollTop  || 0)

    # Bind to and position the tool-palette
    rect = targetControl.el.getBoundingClientRect()
    @palette.$el.css(top: rect.top + top, left: rect.right)

    # Initialize Values
    @$contentRegionControl = targetControl.$el
    @contentRegionId = @$contentRegionControl.data('content-region-id')

    # Request values from the backend.
    #$.ajax
      #type: "GET"
      #url: "/content_items/#{@storyTextId}.json"
      #data:
        #authenticity_token: Newstime.Composer.authenticityToken
      #success: (data) =>
        #@$columnsSelect.val(data['columns'])
        #@$heightInput.val(data['height'])
