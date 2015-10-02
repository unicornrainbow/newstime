
class @Newstime.VideoPropertiesView extends Backbone.View

  tagName: 'ul'

  events:
    'change .video-name-field': 'changeVideoName'

  initialize: ->

    @$el.addClass('video-properties')

    @$el.html """
      <li class="property">
        <label>Video Name</label>
        <span class="field"><input class="video-name-field" style="width: 100px"></input></span>
      </li>

      <li class="property" style="display: none;">
        <label>Video URL</label>
        <span class="field"><input class="video-url-field" style="width: 100px"></input></span>
      </li>

      <li class="property" style="display: none;">
        <label>Cover URL</label>
        <span class="field"><input class="cover-image-url-field" style="width: 100px;"></input></span>
      </li>
    """

    @$videoNameField = @$('.video-name-field')
    @$videoURLField = @$('.video-url-field')
    @$coverImageURLField = @$('.cover-image-url-field')

  render: ->
    @$videoNameField.val(@model.get('video_name') || '')
    this

  changeVideoName: ->
    @model.set 'video_name', @$videoNameField.val()
