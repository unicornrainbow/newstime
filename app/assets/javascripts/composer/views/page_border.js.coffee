# Covers and capture mouse events for relay to interested objects.
class @Newstime.PageBorder extends Backbone.View

  initialize: (options) ->
    @page = options.page
    console.log @page.geometry()
    @model = new Backbone.Model()
    @$el.addClass "page-border"

    @model.bind 'change', @modelChanged, this

  modelChanged: ->
    css = {}
    css.top = @model.get('pageY') + @model.get('pageTopMargin')
    css.left = @model.get('pageX') + @model.get('pageLeftMargin')
    css.width = @model.get('pageWidth') - @model.get('pageLeftMargin') - @model.get('pageRightMargin')
    css.height = @model.get('pageHeight') - @model.get('pageTopMargin') - @model.get('pageBottomMargin')
    @$el.css(css)
