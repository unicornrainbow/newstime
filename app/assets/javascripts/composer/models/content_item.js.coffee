class @Newstime.ContentItem extends Backbone.RelationalModel
  idAttribute: '_id'

  initialize: (attributes) ->
    @set('cursorPosition', (@get('text') || ' ').length, silent: true)

  # Gets page
  page: ->
    @_page ?= @getPage()

  # Gets section
  section: ->
    @page().section()

  # Gets updated page
  getPage: ->
    @_page = @get('edition').get('pages').findWhere(_id: @get('page_id'))

  # Specific to the HeadlineContentItem
  typeCharacter: (char) ->

    if @get('text')
      @set('text', @get('text') + char, silent: true)
      #@set('cursorPosition', @get('cursorPosition') + 1, silent: true)
      @trigger('change')
    else
      @set('text', char, silent: true)
      #@set('cursorPosition', 1, silent: true)
      @trigger('change')


    #if @get('text')
      #@set('text', @get('text').slice(0, @get('cursorPosition'))  + char + @get('text').slice(@get('cursorPosition'), @get('text').length), silent: true)
      #@set('cursorPosition', @get('cursorPosition') + 1, silent: true)
      #@trigger('change')
    #else
      #@set('text', char, silent: true)
      #@trigger('change')

  # Specific to headline content item
  backspace: ->
    @set('text', @get('text').slice(0,-1), silent: true)
    #@set('cursorPosition', Math.max(0, @get('cursorPosition') - 1), silent: true)
    @trigger('change')


class @Newstime.ContentItemCollection extends Backbone.Collection
  model: Newstime.ContentItem

  url: ->
    "#{@edition.url()}/content_items"
