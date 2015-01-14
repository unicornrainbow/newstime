class @Newstime.Group extends Backbone.RelationalModel
  idAttribute: '_id'

  getContentItems: -> # TODO: Should be named getGroupedItems
    @_contentItems = @get('edition').get('content_items').where(group_id: @get('_id'))


  Object.defineProperties @prototype,
    top:
      get: -> @get('top')
      set: (value) ->
        @set 'top', value

    left:
      get: -> @get('left')
      set: (value) ->
        @set 'left', value

  # Gets page
  getPage: ->
    @_page ?= @get('edition').get('pages').findWhere(_id: @get('page_id'))

  setPage: (page) ->
    @_page = page
    @set 'page_id', page.get('_id')

class @Newstime.GroupCollection extends Backbone.Collection
  model: Newstime.Group
  url: ->
    "#{@edition.url()}/groups"
