define [ "underscore", "js/model/WorkModel", "localStorage"], ( _, WorkModel) ->
	Backbone.Collection.extend
		model: WorkModel
		localStorage: new Backbone.LocalStorage("WorkCollection")
		currentWorkTask: ->
			mostRecentWork = @first()
			return mostRecentWork if mostRecentWork and mostRecentWork.isRunning()
			return null
		comparator: (m) ->
			-m.get("startTime").getTime()
		initialize: ->
		destroy: ->