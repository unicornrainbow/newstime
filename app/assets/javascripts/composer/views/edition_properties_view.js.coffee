@Newstime = @Newstime || {}

class @Newstime.EditionPropertiesView extends Backbone.View
  tagName: 'ul'

  events:
    'change .ink-color': 'changeInkColor'
    'change .paper-color': 'changePaperColor'
    'change .line-color': 'changeLineColor'
    'change .selection-color': 'changeSelectionColor'

  initialize: (options) ->

    @$el.addClass('page-properties')

    @$el.html """

      <li class="property">
        <label>Ink</label>
        <span class="field">
          <input class="ink-color" style="width:75px;"></input>
        </span>
      </li>

      <li class="property">
        <label>Paper</label>
        <span class="field">
          <input class="paper-color" style="width:75px;"></input>
        </span>
      </li>


      <li class="property">
        <label>Line</label>
        <span class="field">
          <input class="line-color" style="width:75px;"></input>
        </span>
      </li>


      <li class="property">
        <label>Selection</label>
        <span class="field">
          <input class="selection-color" style="width:75px;"></input>
        </span>
      </li>
    """

    @$paperColor     = @$('.paper-color')
    @$inkColor       = @$('.ink-color')
    @$lineColor      = @$('.line-color')
    @$selectionColor = @$('.selection-color')

    @listenTo @model, 'change', @render

    @render()

  changePaperColor: ->
    @model.set 'paper_color', @$paperColor.val()

  changeInkColor: ->
    @model.set 'ink_color', @$inkColor.val()

  changeLineColor: ->
    @model.set 'line_color', @$lineColor.val()

  changeSelectionColor: ->
    @model.set 'selection_color', @$selectionColor.val()

  render: ->
    @$paperColor.val @model.get('paper_color') if @model.get('paper_color')
    @$inkColor.val @model.get('ink_color') if @model.get('ink_color')
    @$lineColor.val @model.get('line_color') if @model.get('line_color')
    @$selectionValue.val @model.get('selection_color') if @model.get('selection_color')
