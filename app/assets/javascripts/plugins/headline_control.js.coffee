$ ->
  $.fn.headlineControl = ->
    this.each (i, el) ->
      new Newstime.HeadlineControlView(el: el)
