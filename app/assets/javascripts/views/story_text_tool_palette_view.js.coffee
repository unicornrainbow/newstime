@Newstime = @Newstime || {}

class @Newstime.StoryTextToolPaletteView extends Backbone.View

  events:
   'keydown .current-font-size': 'keydownFontSize'
   'keydown .current-font-weight': 'keydownFontWeight'

   'mousedown .title-bar': 'beginDrag'
   'mouseup .title-bar': 'endDrag'

   'keydown .margin-top': 'keydownMarginTop'
   'keydown .margin-bottom': 'keydownMarginBottom'
   'keydown .padding-top': 'keydownPaddingTop'
   'keydown .padding-bottom': 'keydownPaddingBottom'

   'change .current-font-size': 'changeFontSize'
   'change .font-family-select': 'changeFont'
   'change .margin-top': 'changeMarginTop'
   'change .margin-bottom': 'changeMarginBottom'
   'change .padding-top': 'changePaddingTop'
   'change .padding-bottom': 'changePaddingBottom'
   'change .headline-alignment': 'changeAlignment'
   'change .headline-style': 'changeStyle'
   'click .headline': 'changeText'
   'click .dismiss': 'dismiss'

  dismiss: ->
    @save()
    @$el.hide()

  save: ->
    $.ajax
      type: "PUT"
      url: "/content_items/#{@headlineId}.json"
      data:
        authenticity_token: Newstime.Composer.authenticityToken
        content_item:
          font_size: @$headline.css('font-size')
          font_weight: @$headline.css('font-weight')
          font_family: @$headline.css('font-family')
          font_style: @$headline.css('font-style')
          text_align: @$headline.css('text-align')
          margin_top: @$headline.css('margin-top')
          margin_bottom: @$headline.css('margin-bottom')
          padding_top: @$headline.css('padding-top')
          padding_bottom: @$headline.css('padding-bottom')


  moveHandeler: (e) =>
    @$el.css('top', event.pageY + @topMouseOffset)
    @$el.css('left', event.pageX + @leftMouseOffset)

  beginDrag: (e) ->
    # Calulate offsets
    @topMouseOffset = parseInt(@$el.css('top')) - event.pageY
    @leftMouseOffset = parseInt(@$el.css('left')) - event.pageX

    $(document).bind('mousemove', @moveHandeler)

  endDrag: (e) ->
    $(document).unbind('mousemove', @moveHandeler)

  initialize: ->
    @$el.hide()
    @$el.addClass('headline-toolbar')

    @$el.html """
      <div class="title-bar">
        Headline
        <span class="dismiss">x</span>
      </div>
      <div class="palette-body">
        <select class="font-family-select">
          <option value="Exo, sans-serif">Exo</option>
          <option value="EB Garamond, serif">Garamond</option>
        </select>
        <div>
          <select class="headline-alignment">
            <option value="left">Left</option>
            <option value="center">Center</option>
            <option value="right">Right</option>
            <option value="justify">Justify</option>
          </select>
        </div>
        <select class="headline-style">
          <option value="normal">Normal</option>
          <option value="italic">Italic</option>
        </select>
        <br>
        Size: <input class="nt-control current-font-size"></input>
        <br>
        Weight: <input class="nt-control current-font-weight"></input>
        <br>
        Margin:
          <input class="nt-control margin-top"></input>
          <input class="nt-control margin-bottom"></input>
        <br>
        Padding:
          <input class="nt-control padding-top"></input>
          <input class="nt-control padding-bottom"></input>
      </div>
    """
    # Selects
    @$fontSizeInput = @$el.find('.current-font-size')
    @$fontWeightInput = @$el.find('.current-font-weight')
    @$fontFamilySelect = @$el.find('.font-family-select')
    @$headlineAlignment = @$el.find('.headline-alignment')
    @$headlineStyle = @$el.find('.headline-style')

    @$marginTop = @$el.find('.margin-top')
    @$marginBottom = @$el.find('.margin-bottom')
    @$paddingTop = @$el.find('.padding-top')
    @$paddingBottom = @$el.find('.padding-bottom')

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


  keydownMarginTop: (e) ->
    switch e.keyCode
      when 38 then delta = 1
      when 40 then delta = -1

    if delta
      value = @$marginTop.val()
      value = "#{parseInt(value)+delta}px"
      @$headline.css('margin-top', value)
      @$marginTop.val(value)


  keydownMarginBottom: (e) ->
    switch e.keyCode
      when 38 then delta = 1
      when 40 then delta = -1

    if delta
      value = @$marginBottom.val()
      value = "#{parseInt(value)+delta}px"
      @$headline.css('margin-bottom', value)
      @$marginBottom.val(value)


  keydownPaddingTop: (e) ->
    switch e.keyCode
      when 38 then delta = 1
      when 40 then delta = -1

    if delta
      value = @$paddingTop.val()
      value = "#{parseInt(value)+delta}px"
      @$headline.css('padding-top', value)
      @$paddingTop.val(value)


  keydownPaddingBottom: (e) ->
    switch e.keyCode
      when 38 then delta = 1
      when 40 then delta = -1

    if delta
      value = @$paddingBottom.val()
      value = "#{parseInt(value)+delta}px"
      @$headline.css('padding-bottom', value)
      @$paddingBottom.val(value)

  changeFontSize: (e) ->
    @$headline.css 'font-size': $(e.currentTarget).val()

  changeStyle: (e) ->
    @$headline.css 'font-style': $(e.currentTarget).val()

  changeAlignment: (e) ->
    @$headline.css 'text-align': $(e.currentTarget).val()

  changePaddingTop: (e) ->
    console.log('asd')
    @$headline.css 'padding-top': $(e.currentTarget).val()

  changePaddingBottom: (e) ->
    @$headline.css 'padding-bottom': $(e.currentTarget).val()

  changeMarginTop: (e) ->
    @$headline.css 'margin-top': $(e.currentTarget).val()

  changeMarginBottom: (e) ->
    @$headline.css 'margin-bottom': $(e.currentTarget).val()

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


  setHeadlineControl: (headlineControl) ->
    # Scroll offset
    doc = document.documentElement
    body = document.body
    left = (doc && doc.scrollLeft || body && body.scrollLeft || 0)
    top = (doc && doc.scrollTop  || body && body.scrollTop  || 0)

    # Bind to and position the toolbar
    rect = headlineControl.el.getBoundingClientRect()

    #console.log(, rect.right, rect.bottom, rect.left)
    @$el.css(top: rect.top + top, left: rect.right)

    # Initialize Values
    @$headline = headlineControl.$el
    @headlineId = @$headline.data('headline-id')

    @$fontSizeInput.val(@$headline.css('font-size'))
    @$fontWeightInput.val(@$headline.css('font-weight'))
    @$fontFamilySelect.val(@$headline.css('font-family'))
    @$headlineStyle.val(@$headline.css('font-style'))
    @$headlineAlignment.val(@$headline.css('text-align'))
    @$headline.css('text-align')

    @$marginTop.val(@$headline.css('margin-top'))
    @$marginBottom.val(@$headline.css('margin-bottom'))
    @$paddingTop.val(@$headline.css('padding-top'))
    @$paddingBottom.val(@$headline.css('padding-bottom'))


    @$el.show()
