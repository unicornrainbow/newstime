@Newstime = @Newstime || {}


class @Newstime.PhotoPropertiesView extends Backbone.View
  tagName: 'ul'

  events:
    'change .caption': 'updateCaption'

  initialize: ->

    @$el.addClass('newstime-photo-properties')

    @$el.html """
      <li class="property">
        <label>Caption</label>
        <span class="field">
          <input class='caption' type="checkbox"></input>
        </span>
      </li>

      <li class="property">
        <label>Height</label>
        <span class="field"><input></input></spa>
      </li>

      <li class="property">
        <label>Width</label>
        <span class="field"><input></input></spa>
      </li>
    """

  updateCaption: ->
    console.log 'Caption'

    #@$caption = @$('caption')





#class @Newstime.PhotoPropertiesView extends Backbone.View

  #initialize: ->
    #@palette = new Newstime.PaletteView(title: "Photo")
    #@palette.attach(@$el)

    #@$el.addClass('newstime-photo-properties')

    #@$el.html """
    #"""

  #setPhotoControl: (targetControl) ->
    ## Scroll offset
    #doc = document.documentElement
    #body = document.body
    #left = (doc && doc.scrollLeft || body && body.scrollLeft || 0)
    #top = (doc && doc.scrollTop  || body && body.scrollTop  || 0)

    ## Bind to and position the tool-palette
    #rect = targetControl.el.getBoundingClientRect()
    #@palette.$el.css(top: rect.top + top, left: rect.right)

    ## Initialize Values
    #@$photoControl = targetControl.$el
    #@photoId = @$photoControl.data('photo-id')

    ## Request values from the backend.
    ##$.ajax
      ##type: "GET"
      ##url: "/photos/#{@photoId}.json"
      ##data:
        ##authenticity_token: Newstime.Composer.authenticityToken
      ##success: (data) =>
        ##@$contentRegionWidth.val(data['column_width'])

  ## TODO: Generalize to floating tool pallete abstraction
  #setPosition: (top, left) ->
    ## Scroll offset
    #doc = document.documentElement
    #body = document.body
    #leftOffset = (doc && doc.scrollLeft || body && body.scrollLeft || 0)
    #topOffset = (doc && doc.scrollTop  || body && body.scrollTop  || 0)

    ## If greater than a certain distance to the right, subtract the width to
    ## counter act.

    #if leftOffset + left > 1000
      #left = left - @palette.width()

    #@palette.setPosition(topOffset + top, leftOffset + left)

  #show: ->
    #@palette.show()
