@Newstime = @Newstime || {}

class @Newstime.HeadlineControlView extends Backbone.View

  events:
   'keydown .current-font-size': 'keydownFontSize'
   'change .current-font-size': 'changeFontSize'
   'change .font-family-select': 'changeFont'
   'change .headline-alignment': 'changeAlignment'
   'click .headline': 'changeText'

  changeText: ->
    @$headline.text(prompt "Headline Text", @$headline.text())

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

  changeFont: (e) ->
    @$headline.css 'font-family': $(e.currentTarget).val()

  initialize: ->
    @$el.addClass('headline-control')

    @$el.prepend """
      <div class="headline-tools">
        <select class=">
          <option value=""></option>
          <option value="Exo">Exo</option>
        </select>
        <select class="headline-alignment">
          <option value="left">Left</option>
          <option value="center">Center</option>
          <option value="right">Right</option>
        </select>
        <input class="nt-control current-font-size"></input>
        <input class="nt-control current-font-weight"></input>
      </div>
    """

    # Selects
    @$headline = @$el.find('h1')
    @$fontSizeInput = @$el.find('.current-font-size')
    @$headlineAlignment = @$el.find('headline-alignment')
    # Initialize font size
    @$fontSizeInput.val(@$headline.css('font-size'))
