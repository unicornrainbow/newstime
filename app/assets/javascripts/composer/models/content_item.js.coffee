class @Newstime.ContentItem extends Backbone.RelationalModel
  idAttribute: '_id'
  url: ->
    "#{@get('edition').url()}/content_items/#{@get('_id')}"

class @Newstime.ContentItemCollection extends Backbone.Collection
  model: Newstime.ContentItem
