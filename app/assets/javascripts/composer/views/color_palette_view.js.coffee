#= require ../views/panel_view

class @Newstime.ColorPalatteView extends @Newstime.PanelView

  _.extend @::events,
    'click .add-color': 'addColor'
    'click .page-color swatch': 'togglePageColorActive'
    'click .ink-color swatch': 'toggleInkColorActive'
    'click .colors li': 'fill'

  initializePanel: ->
    @edition = @composer.edition

    @$el.addClass('newstime-color-palatte')

    @model.set(width: 150, height: 200)

    @setPosition(470, 70)

    @$body.html """

      <li class="page-color"><swatch color="#{@composer.edition.get('page_color')}"></swatch>Page Color</li>
      <li class="ink-color"><swatch color="#{@composer.edition.get('ink_color')}"></swatch>Ink Color</li>

      <ul class="colors">
      </ul>

      <ul>
        <li class="add-color">Add Color</li>
      </ul>
    """

    swatchMethods =
      setColor: (value) ->
        this.css 'background-color': value

    $.fn.swatch = (methodOrOptions) ->
      this.each ->
        $this = $(this)
        $this.addClass 'swatch'
        $this.css 'background-color': $this.attr('color')


    @$colorList = @$('.colors')
    @$pageColor = @$('.page-color')
    @$pageColorSwatch = $('swatch', @$pageColor).swatch()
    @$inkColor  = @$('.ink-color')

    @$swatches = $('swatch', @$body).swatch()

    @composer.edition.get('colors').forEach (color) =>
      html = $ """
        <li><swatch color="#{color.value}"></swatch>#{color.name}</li>
      """
      swatch = $('swatch', html).swatch()
      html.appendTo @$colorList

    @listenTo @edition, 'change:page_color', @updatePageColor
    @listenTo @edition, 'change:ink_color', @updateInkColor

  updatePageColor: (edition, newValue) ->
    #@$pageColor.swatch('setColor', newValue)
    $('swatch', @$pageColor).css 'background-color': newValue

  updateInkColor: (e, value) ->
    $('swatch', @$inkColor).css 'background-color': value

  fill: (e) ->
    colorValue = $(e.target).attr('color')
    if @pageColorActive
      @composer.edition.set('page_color', colorValue)

    if @inkColorActive
      @composer.edition.set('ink_color', colorValue)

  togglePageColorActive: ->
    @pageColorActive = !@pageColorActive
    if @pageColorActive
      @inkColorActive = false
      @$inkColor.removeClass 'active'

      @$pageColor.addClass 'active'
    else
      @$pageColor.removeClass 'active'

  toggleInkColorActive: ->
    @inkColorActive = !@inkColorActive
    if @inkColorActive
      @pageColorActive = false
      @$pageColor.removeClass 'active'

      @$inkColor.addClass 'active'
    else
      @$inkColor.removeClass 'active'


  addColor: ->
    createColorView = new Newstime.CreateColorView
      respondTo: this
    createColorView.attachPanel()
    createColorView.show()

  createColor: (name, value) ->
    @composer.edition.get('colors').add
      name: name
      value: value

    html = $ """
      <li><swatch color="#{value}"></swatch>#{name}</li>
    """

    swatch = $('swatch', html).swatch()

    html.appendTo @$colorList
