class @Newstime.Page extends Backbone.RelationalModel
  idAttribute: '_id'

  getHTML: (success) ->
    # Example of get html for page
    $.ajax
      url: "#{@url()}.html"
      data:
        composing: true
      success: success
      #success: (data) ->
        #console.log data

  contentItems: ->
    @_contentItems ?= @getContentItems()

  section: ->
    @_section ?= @getSection()

  getContentItems: ->
    @content_items = @get('edition').get('content_items').where(page_id: @get('_id'))

  getSection: ->
    @_section = @get('edition').get('sections').findWhere(_id: @get('section_id'))

class @Newstime.PageCollection extends Backbone.Collection
  model: Newstime.Page
  url: ->
    "#{@edition.url()}/pages"
