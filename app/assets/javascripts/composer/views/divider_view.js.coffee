#= require ./content_item_view

class @Newstime.DividerView extends @Newstime.ContentItemView

  contentItemClassName: 'divider-view'

  initializeContentItem: ->
    #@setContentEl(options.contentEl) if options.contentEl
    #@modelChanged()

    @elementStyles = 'divider'


  @getter 'uiLabel', -> "Divider"


  render: ->
    @$el.css @model.pick 'width', 'top', 'left'
    @$el.css 'z-index': @model.get('z_index')

    @$el.attr 'class', "#{@elementStyles} #{@model.get('style_class')} #{@model.get('orientation')}"

    #photoSize =  @model.pick('height', 'width')
    #photoSize.height -=  @model.get('caption_height')

    #@$el. photoSize
    #

  _createPropertiesView: ->
    new Newstime.DividerPropertiesView(target: this, model: @model).render()

  _createModel: ->
    @edition.contentItems.add({_type: 'DividerContentItem'})
