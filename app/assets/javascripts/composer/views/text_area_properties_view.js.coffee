@Newstime = @Newstime || {}

class @Newstime.TextAreaPropertiesView extends Backbone.View
  tagName: 'ul'

  events:
    'change .story-content-item-columns': 'changeColumns'

  initialize: (options) ->
    @$el.addClass 'text-area-properties'
    @textAreaView = options.target # Text area view

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
        <span class="field"><input class="height-input"></input></spa>
      </li>

      <li class="property">
        <label>Width</label>
        <span class="field"><input class="width-input"></input></spa>
      </li>

      <li class="property">
        <label>By Line</label>
        <span class="field">
          <input class='caption-field' type="checkbox"></input>
        </span>
      </li>

      <li class="property">
        <label>Lead</label>
        <span class="field">
          <select class="text-area-continued-from">
            <option value="">Text Areas...</option>
          </select>
        </span>
      </li>

      <li class="property">
        <label>Follow</label>
        <span class="field">
          <select class="text-area-continued-from">
            <option value="">Text Areas...</option>
          </select>
        </span>
      </li>
    """

    @$columns = @$('.story-content-item-columns')
    @$heightInput = @$('.height-input')
    @$widthInput = @$('.width-input')

    @model.bind 'change', @render, this

    @render()

  render: ->
    @$columns.val(@model.get('columns'))
    @$heightInput.val(@model.get('height') + 'px')
    @$widthInput.val(@model.get('width') + 'px')

  changeColumns: ->
    @model.set 'columns', @$columns.val()
    @textAreaView.reflow()
