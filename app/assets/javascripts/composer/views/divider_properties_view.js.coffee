
class @Newstime.DividerPropertiesView extends Backbone.View

  tagName: 'ul'

  events:
   'change .style-select': 'changeStyle'
   'change .orientation-select': 'changeOrientation'

  initialize: ->
    @$el.addClass('divider-properties')

    @$el.html """
      <li class="property">
        <label>Orientation</label>
        <span class="field">
          <select class="orientation-select">
            <option value="horizontal">Horizontal</option>
            <option value="vertical">Vertical</option>
          </select>
        </span>
      </li>
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
    @$orientationSelect = @$('.orientation-select')

    @listenTo @model, 'change', @render

    @render()


  render: ->
    @$styleSelect.val(@model.get('style_class')) if @model.get('style_class')
    @$orientationSelect.val(@model.get('orientation')) if @model.get('orientation')

    this

  changeStyle: (e) ->
    @model.set('style_class': $(e.currentTarget).val())

  changeOrientation: (e) ->
    @model.set('orientation': $(e.currentTarget).val())
