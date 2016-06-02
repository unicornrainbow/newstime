#= require ../views/panel_view

class @Newstime.CreateColorView extends Newstime.PanelView

  _.extend @::events,
    'click .create-color': 'createColor'

  initializePanel: (options) ->
    @respondTo = options['respondTo']
    @$el.addClass('newstime-create-color')
    @$el.addClass('newstime-properties-panel')

    @model.set width: 250, height: 400

    @setPosition 200, 300

    @$body.html """
      <ul>
      <li class="property">
        <label>Name</label>
        <span class="field">
          <input class="color-name" style="width: 100px"></input>
        </span>
      </li>
      <li class="property">
        <label>Value</label>
        <span class="field">
          <input class="color-value" style="width: 100px"></input>
        </span>
      </li>
      </ul>
      <button class="create-color">Add Color</button>
    """

    @$colorName  = @$('.color-name')
    @$colorValue = @$('.color-value')

  createColor: ->
    name = @$colorName.val()
    value = @$colorValue.val()
    @respondTo.createColor(name, value)
    @detachPanel()

  # Attaches panel to composer
  attachPanel: ->
    @composer.attachPanel(this)

  # Detaches panel from composer
  detachPanel: ->
    @composer.detachPanel(this)
