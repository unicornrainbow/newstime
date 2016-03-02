class @Newstime.PhotoPickerView extends Backbone.View

  events:
    'click .photo-thumbnail': 'selectPhoto'

  initialize: (options) ->
    @window = options.window
    @$el.addClass "photo-picker"
    @loadPhotos()

  loadPhotos: ->
    # Need to query server for list of photos
    $.ajax
      method: 'GET'
      url: "/photos.json"
      success: (response) =>
        i = 0
        _.each response, (photo) =>
          @$el.append """
            <div class="photo-thumbnail"
                 data-photo-id="#{photo._id}"
                 data-edition-relative-url-path="#{photo.edition_relative_url_path}"
                 style="background-image: url('#{photo.edition_relative_url_path}')"></div>
          """
          if i == 4
            @$el.append "<br>"
            i = 0
          else
            i++

  selectPhoto: (e) =>
    photoId = $(e.target).data('photo-id')
    url = $(e.target).data('edition-relative-url-path')

    respondToModel = @window.respondToView.model
    respondToModel.set
      photo_id: photoId
      edition_relative_url_path: url

    @window.respondToView = null
    @window.hide()
