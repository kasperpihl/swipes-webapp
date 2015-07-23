define [
	"underscore"
	"js/collection/ToDoCollection"
	"js/collection/MemberCollection"
	"js/collection/TagCollection"
	"js/collection/ProjectCollection"
	"js/collection/WorkCollection"
	"js/collection/MessageCollection"
	"plugins/backbone.collectionsubset"
	], (_, ToDoCollection, MemberCollection, TagCollection, ProjectCollection, WorkCollection, MessageCollection) ->
	class Collections
		constructor: ->
			@todos = new ToDoCollection()
			@members = new MemberCollection()
			@tags = new TagCollection()
			@projects = new ProjectCollection()
			@workSessions = new WorkCollection()
			@messages = new MessageCollection()
			@all = [@members, @projects, @tags, @messages, @todos,  @workSessions]
		fetchAll: ->
			for collection in @all
				collection.fetch()