class @Newstime.Edition extends Backbone.RelationalModel
  urlRoot: '/editions/'
  idAttribute: '_id'

  relations: [{
    type: Backbone.HasMany
    key: 'sections'
    relatedModel: 'Newstime.Section'
    collectionType: 'Newstime.SectionCollection'
    keySource: 'sections_attributes'
    reverseRelation: {
      key: 'edition'
      includeInJSON: '_id'
    }
  }
  {
    type: Backbone.HasMany
    key: 'pages'
    relatedModel: 'Newstime.Page'
    collectionType: 'Newstime.PageCollection'
    keySource: 'pages_attributes'
    reverseRelation: {
      key: 'edition'
      includeInJSON: '_id'
    }
  }
  {
    type: Backbone.HasMany
    key: 'content_items'
    relatedModel: 'Newstime.ContentItem'
    collectionType: 'Newstime.ContentItemCollection'
    keySource: 'content_items_attributes'
    reverseRelation: {
      key: 'edition'
      includeInJSON: '_id'
    }
  }]

  initialize: (attributes, options) ->


class @Newstime.ContentItem extends Backbone.RelationalModel
  idAttribute: '_id'
  url: ->
    "#{@get('edition').url()}/content_items/#{@get('_id')}"

class @Newstime.ContentItemCollection extends Backbone.Collection
  model: Newstime.ContentItem


class @Newstime.Section extends Backbone.RelationalModel


class @Newstime.SectionCollection extends Backbone.Collection
  model: Newstime.Section


class @Newstime.Page extends Backbone.RelationalModel


class @Newstime.PageCollection extends Backbone.Collection
  model: Newstime.Page
