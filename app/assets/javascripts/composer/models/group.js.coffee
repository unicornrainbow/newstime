class @Newstime.Group extends Backbone.RelationalModel
  idAttribute: '_id'

  getContentItems: ->
    @_contentItems = @get('edition').get('content_items').where(group_id: @get('_id'))

class @Newstime.GroupCollection extends Backbone.Collection
  model: Newstime.Group
  url: ->
    "#{@edition.url()}/groups"
