define [
	"underscore"
	"js/collection/ToDoCollection"
	"js/collection/TagCollection"
	"js/collection/WorkCollection"
	"plugins/backbone.collectionsubset"
	], (_, ToDoCollection, TagCollection, WorkCollection) ->
	class Collections
		constructor: ->
			### 
				Extend backbone models to have an exclude pattern
			###
			oldToJSON = Backbone.Model.prototype.toJSON
			Backbone.Model.prototype.toJSON = ->
				json = oldToJSON.apply(@, arguments)
				excludeFromJSON = @excludeFromJSON
				if excludeFromJSON
					_.each(excludeFromJSON, (key) ->
						delete json[key]
					)
				return json


			@todos = new ToDoCollection()
			@tags = new TagCollection()
			@workSessions = new WorkCollection()

			@all = [@tags, @todos,  @workSessions]
		fetchAll: ->
			for collection in @all
				collection.fetch()