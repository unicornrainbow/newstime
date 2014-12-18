@Newstime = @Newstime || {}

class @Newstime.TextAreaPropertiesView extends Backbone.View
  tagName: 'ul'

  initialize: ->
    @$el.addClass 'text-area-properties'

    @$el.html """
      <li class="property">
        <label>Columns</label>
        <span class="field">
          <select class="story-content-item-columns">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
          </select>
        </span>
      </li>


      <li class="property">
        <label>Height</label>
        <span class="field"><input></input></spa>
      </li>
    """
