define [
	"underscore"
	"js/collection/ToDoCollection"
	"js/collection/TagCollection"
	"js/collection/ProjectCollection"
	"js/collection/WorkCollection"
	"plugins/backbone.collectionsubset"
	], (_, ToDoCollection, TagCollection, ProjectCollection, WorkCollection) ->
	class Collections
		constructor: ->
			@todos = new ToDoCollection()
			@tags = new TagCollection()
			@projects = new ProjectCollection()
			@workSessions = new WorkCollection()
			@all = [@tags, @todos, @projects, @workSessions]
		fetchAll: ->
			for collection in @all
				collection.fetch()