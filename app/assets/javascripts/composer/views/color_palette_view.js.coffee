#= require ../views/panel_view

class @Newstime.ColorPalatteView extends @Newstime.PanelView

  _.extend @::events,
    'click .add-color': 'addColor'

  initializePanel: ->
    @$el.addClass('newstime-color-palatte')

    @model.set(width: 150, height: 200)

    @setPosition(470, 70)

    @$body.html """
      <ul class="colors">
      <li><swatch color="#{@composer.edition.get('page_color')}"></swatch>Page Color</li>
      <li><swatch color="#{@composer.edition.get('ink_color')}"></swatch>Ink Color</li>
      </ul>

      <ul>
        <li class="add-color">Add Color</li>
      </ul>
    """

    $.fn.swatch = ->
      this.each ->
        $this = $(this)
        $this.addClass 'swatch'
        $this.css 'background-color': $this.attr('color')


    @$colorList = @$('.colors')

    @$swatches = $('swatch', @$body).swatch()

    @composer.edition.get('colors').forEach (color) =>
      html = $ """
        <li><swatch color="#{color.value}"></swatch>#{color.name}</li>
      """
      swatch = $('swatch', html).swatch()
      html.appendTo @$colorList



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
