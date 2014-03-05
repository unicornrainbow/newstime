@Newstime = @Newstime || {}

class @Newstime.HeadlineToolbarView extends Backbone.View

  initialize: ->
    @$el.addClass('headline-toolbar')

    @$el.html """
      <select class="font-family-select">
        <option value="Exo, sans-serif">Exo</option>
        <option value="EB Garamond, serif">Garamond</option>
      </select>
      <select class="headline-alignment">
        <option value="left">Left</option>
        <option value="center">Center</option>
        <option value="right">Right</option>
      </select>
      <select class="headline-style">
        <option value="normal">Normal</option>
        <option value="italic">Italic</option>
      </select>
      <input class="nt-control current-font-size"></input>
      <input class="nt-control current-font-weight"></input>
    """

    # Selects
    @$headline = @$el.find('h1')
    @$fontSizeInput = @$el.find('.current-font-size')
    @$fontWeightInput = @$el.find('.current-font-weight')
    @$fontFamilySelect = @$el.find('.font-family-select')
    @$headlineAlignment = @$el.find('headline-alignment')
    # Initialize font size
    @$fontSizeInput.val(@$headline.css('font-size'))
    @$fontWeightInput.val(@$headline.css('font-weight'))
    @$fontFamilySelect.val(@$headline.css('font-family'))

  events:
   'keydown .current-font-size': 'keydownFontSize'
   'keydown .current-font-weight': 'keydownFontWeight'
   'change .current-font-size': 'changeFontSize'
   'change .font-family-select': 'changeFont'
   'change .headline-alignment': 'changeAlignment'
   'click .headline': 'changeText'

  changeText: ->
    text = prompt("Headline Text", @$headline.text())
    text = text.replace('\\n', "<br>")
    @$headline.html(text) if text

  keydownFontSize: (e) ->
    switch e.keyCode
      when 38 then delta = 1
      when 40 then delta = -1

    if delta
      fontSize = @$fontSizeInput.val()
      fontSize = "#{parseInt(fontSize)+delta}px"
      @$headline.css('font-size', fontSize)
      @$fontSizeInput.val(fontSize)

  changeFontSize: (e) ->
    @$headline.css 'font-size': $(e.currentTarget).val()

  changeAlignment: (e) ->
    @$headline.css 'text-align': $(e.currentTarget).val()

  keydownFontWeight: (e) ->
    switch e.keyCode
      when 38 then delta = 100
      when 40 then delta = -100

    if delta
      fontWeight = @$fontWeightInput.val()
      fontWeight = "#{parseInt(fontWeight)+delta}"
      @$headline.css('font-weight', fontWeight)
      @$fontWeightInput.val(fontWeight)


  changeFont: (e) ->
    @$headline.css 'font-family': $(e.currentTarget).val()