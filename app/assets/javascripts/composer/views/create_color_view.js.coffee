#= require ../views/panel_view
#= require lib/hsl_to_rgb

class @Newstime.CreateColorView extends Newstime.PanelView

  _.extend @::events,
    'click .create-color': 'createColor'
    'input #hue-slider': 'updateHue'
    'mousemove .color-preview': 'trackColor'
    'mousedown .color-preview': 'mousedownColorPreview'
    'mouseup   .color-preview': 'mouseupColorPreview'

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
      <input id='hue-slider' type=range min=0 max=100></input>
      <div class="color-preview"></div>
      <button class="create-color">Add Color</button>
    """

    @$colorName  = @$('.color-name')
    @$colorValue = @$('.color-value')
    @$colorPreview = @$('.color-preview')
    @$hueSlider    = @$('#hue-slider')

  createColor: ->
    name = @$colorName.val()
    value = @$colorValue.val()
    @respondTo.createColor(name, value)
    @detachPanel()

  updateHue: ->
    @hue = @$hueSlider.val()/100
    rgb = hslToRgb(@hue, @saturation, @lightness)
    @$colorPreview.css 'background-color', "rgb(#{rgb[0]}, #{rgb[1]}, #{rgb[2]});"

    #"hsl(#{hue}, 50, 50)"

  # Attaches panel to composer
  attachPanel: ->
    @composer.attachPanel(this)

  # Detaches panel from composer
  detachPanel: ->
    @hide()
    @composer.detachPanel(this)

  trackColor: (e) ->
    if @trackingColor

      @saturation = e.offsetX/200
      @lightness  = e.offsetY/200
      rgb = hslToRgb(@hue, @saturation, @lightness)
      @$colorPreview.css 'background-color', "rgb(#{rgb[0]}, #{rgb[1]}, #{rgb[2]});"
      @$colorValue.val(@rgbToHex(rgb[0], rgb[1], rgb[2]))

  mousedownColorPreview: ->
    @trackingColor = true

  mouseupColorPreview: ->
    @trackingColor = false

  componentToHex: (c) ->
    hex = c.toString(16)
    if hex.length == 1 then  "0" + hex else hex

  rgbToHex: (r, g, b) ->
    "\##{@componentToHex(r)}#{@componentToHex(g)}#{@componentToHex(b)}"
