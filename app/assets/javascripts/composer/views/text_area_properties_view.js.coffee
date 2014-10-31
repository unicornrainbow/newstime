@Newstime = @Newstime || {}

class @Newstime.TextAreaPropertiesView extends Backbone.View

  initialize: ->

    @$el.addClass('text-area-properties')

    @$el.html """
      <div>
      Column:
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
      <a class="story-link" href="">Story</a>
      <br>
      <a class="story-reflow" href="">Reflow</a>
      <br>
      <a class="story-delete" href="">Delete</a>
    """
