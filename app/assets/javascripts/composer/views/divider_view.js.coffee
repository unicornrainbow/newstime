#= require ./content_item_view

class @Newstime.DividerView extends @Newstime.ContentItemView

  contentItemClassName: 'divider-view'

  initializeContentItem: ->
    #@setContentEl(options.contentEl) if options.contentEl
    #@modelChanged()

    @elementStyles = @$el.attr('class')


  render: ->
    super

    #console.log "as"

  @getter 'uiLabel', -> "Divider"


  render: ->
    @$el.css @model.pick 'width', 'top', 'left'
    @$el.css 'z-index': @model.get('z_index')

    @$el.attr 'class', @elementStyles # Reset class list to not include and style class
    @$el.addClass @model.get('style_class') if @model.get('style_class')

    console.log @$el

    #photoSize =  @model.pick('height', 'width')
    #photoSize.height -=  @model.get('caption_height')

    #@$el. photoSize
    #

  _createPropertiesView: ->
    new Newstime.DividerPropertiesView(target: this, model: @model).render()

  _createModel: ->
    @edition.contentItems.add({_type: 'DividerContentItem'})
