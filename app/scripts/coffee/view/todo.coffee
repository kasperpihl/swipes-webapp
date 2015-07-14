define ["underscore", "js/view/List", "js/view/workmode/RequestWorkOverlay"], (_, ListView, RequestWorkOverlay) ->
	ListView.extend
		initialize: ->
			@state = "tasks"
			ListView::initialize.apply( @, arguments )
			Backbone.on( "request-work-task", @requestWorkTask, @ )
		requestWorkTask: ( task ) ->
			@workEditor = new RequestWorkOverlay( model: task )
		sortTasks: (tasks) ->
			return _.sortBy tasks, (model) -> model.get "order" 
		groupTasks: (tasksArr) ->
			tasksArr = @sortTasks tasksArr
			return [ { deadline: "Tasks", tasks: tasksArr } ]
		afterMovedItems: ->
			if @getTasks().length is 0
				todayOrNow = "For Today"
				swipy.analytics.sendEvent("Actions", "Cleared Tasks", todayOrNow, 0)
				swipy.analytics.sendEventToIntercom("Cleared Tasks", {"Streak": 0, "All Done for Today": todayOrNow, "Sharing Services Available": 0})
			ListView::afterMovedItems.apply( @, arguments )