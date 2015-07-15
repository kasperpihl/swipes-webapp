define [
	"underscore"
	"js/collection/ToDoCollection"
	"js/collection/MemberCollection"
	"js/collection/TagCollection"
	"js/collection/ProjectCollection"
	"js/collection/WorkCollection"
	"plugins/backbone.collectionsubset"
	], (_, ToDoCollection, MemberCollection, TagCollection, ProjectCollection, WorkCollection) ->
	class Collections
		constructor: ->
			@todos = new ToDoCollection()
			@members = new MemberCollection()
			@tags = new TagCollection()
			@projects = new ProjectCollection()
			@workSessions = new WorkCollection()
			@all = [@tags, @members, @todos, @projects, @workSessions]
		fetchAll: ->
			for collection in @all
				collection.fetch()