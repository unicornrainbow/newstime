@Newstime = @Newstime || {}

class @Newstime.EditionPropertiesView extends Backbone.View
  tagName: 'ul'

  events:
    'change .ink-color': 'changeInkColor'
    'change .page-color': 'changePageColor'
    'change .line-color': 'changeLineColor'
    'change .selection-color': 'changeSelectionColor'

  initialize: (options) ->

    @$el.addClass('page-properties')

    @$el.html """
      <li class="property" style="display: none;">
        <label>Ink</label>
        <span class="field">
          <input class="ink-color" style="width:75px;"></input>
        </span>
      </li>

      <li class="property" style="display: none;">
        <label>Page</label>
        <span class="field">
          <input class="page-color" style="width:75px;"></input>
        </span>
      </li>


      <li class="property" style="display: none;">
        <label>Line</label>
        <span class="field">
          <input class="line-color" style="width:75px;"></input>
        </span>
      </li>


      <li class="property" style="display: none;">
        <label>Selection</label>
        <span class="field">
          <input class="selection-color" style="width:75px;"></input>
        </span>
      </li>
    """

    @$pageColor     = @$('.page-color')
    @$inkColor       = @$('.ink-color')
    @$lineColor      = @$('.line-color')
    @$selectionColor = @$('.selection-color')

    @listenTo @model, 'change', @render

    @render()

  changePageColor: ->
    @model.set 'page_color', @$pageColor.val()

  changeInkColor: ->
    @model.set 'ink_color', @$inkColor.val()

  changeLineColor: ->
    @model.set 'line_color', @$lineColor.val()

  changeSelectionColor: ->
    @model.set 'selection_color', @$selectionColor.val()

  render: ->
    @$pageColor.val @model.get('page_color') if @model.get('page_color')
    @$inkColor.val @model.get('ink_color') if @model.get('ink_color')
    @$lineColor.val @model.get('line_color') if @model.get('line_color')
    @$selectionValue.val @model.get('selection_color') if @model.get('selection_color')
