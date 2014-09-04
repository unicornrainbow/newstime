class @Newstime.Edition extends Backbone.RelationalModel
	urlRoot: '/editions/'
	idAttribute: '_id'

	relations: [{
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


class @Newstime.ContentItemCollection extends Backbone.Collection
	model: Newstime.ContentItem
