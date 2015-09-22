
class @Newstime.DividerPropertiesView extends Backbone.View

  tagName: 'ul'

  events:
   'change .style-select': 'changeStyle'

  initialize: ->
    @$el.addClass('divider-properties')

    @$el.html """
      <li class="property">
        <label>Style</label>
        <span class="field">
          <select class="style-select">
            <option value="Single">Single</option>
            <option value="news-column-double-rule">Double</option>
          </select>
        </span>
      </li>
    """

    @$styleSelect = @$('.style-select')

    @listenTo @model, 'change', @render

    @render()


  render: ->
    @$styleSelect.val(@model.get('style_class')) if @model.get('style_class')

    this

  changeStyle: (e) ->
    @model.set('style_class': $(e.currentTarget).val())
