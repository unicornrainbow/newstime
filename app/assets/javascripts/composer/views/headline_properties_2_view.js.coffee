@Newstime = @Newstime || {}

class @Newstime.HeadlineProperties2View extends Backbone.View
  tagName: 'ul'

  initialize: ->

    @$el.addClass('headline-properties')

    @$el.html """

      <li class="property">
        <label>Font</label>
        <span class="field">
          <select class="font-family-select">
            <option value="Exo, sans-serif">Exo</option>
            <option value="EB Garamond, serif">Garamond</option>
          </select>
        </span>
      </li>

      <li class="property">
        <label>Style</label>
        <span class="field">
          <select class="headline-style">
            <option value="normal">Normal</option>
            <option value="italic">Italic</option>
          </select>
        </span>
      </li>
      <li class="property">
        <label>Size</label>
        <span class="field">
          <input class=""></input>
        </span>
      </li>
      <li class="property">
        <label>Weight</label>
        <span class="field">
          <input class=""></input>
        </span>
      </li>
    """

    @
