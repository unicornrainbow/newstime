@Newstime = @Newstime || {}

class @Newstime.HeadlinePropertiesView extends Backbone.View
  tagName: 'ul'

  events:
   'change .font-family-select': 'changeFont'
   'change .headline-style': 'changeStyle'
   'change .color': 'changeColor'

  initialize: (options) ->
    @headlineView = options.target

    @$el.addClass('headline-properties')

    @$el.html """
      <li class="property">
        <label>Font</label>
        <span class="field">
          <select class="font-family-select">
            <option value="Exo, sans-serif">Exo</option>
            <option value="EB Garamond, serif">Garamond</option>
            <option value="Sacramento, cursive">Sacramento</option>
            <option value="'Cedarville Cursive', cursive">Cedarville Cursive</option>
            <option value="'Mrs Saint Delafield', cursive">Mrs Saint Delafield</option>
            <option value="'Ruge Boogie', cursive">Ruge Boogie</option>
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
        <label>Font Size</label>
        <span class="field">
          <input class="font-size"></input>
        </span>
      </li>
      <li class="property">
        <label>Weight</label>
        <span class="field">
          <input class="font-weight"></input>
        </span>
      </li>
      <li class="property">
        <label>Color</label>
        <span class="field">
          <input class="color" style="width: 100px;"></input>
        </span>
      </li>
    """

    @$fontFamilySelect = @$('.font-family-select')
    @$headlineStyleSelect = @$('.headline-style')
    @$fontSize = @$('.font-size')
    @$fontWeight = @$('.font-weight')
    @$color = @$('.color')

    @listenTo @model, 'change', @render

    @render()

  render: ->
    @$fontFamilySelect.val(@model.get('font_family')) if @model.get('font_family')
    @$headlineStyleSelect.val(@model.get('font_style'))
    @$fontSize.val(@model.get('font_size'))
    @$fontWeight.val(@model.get('font_weight'))
    @$color.val(@model.get('color'))

  changeFont: (e) ->
    @model.set('font_family': $(e.currentTarget).val())
    @headlineView.fitToBorderBox()

  changeStyle: (e) ->
    @model.set('font_style': $(e.currentTarget).val())

  changeColor: (e) ->
    @model.set(color: $(e.currentTarget).val())

  #changeFontSize: (e) ->
