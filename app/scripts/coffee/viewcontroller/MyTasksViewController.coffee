define [
	"underscore"
	"gsap"
	"js/viewcontroller/TaskListViewController"
	], (_, TweenLite, TaskListViewController) ->
	Backbone.View.extend
		className: "my-tasks-view-controller"
		initialize: ->
			@taskListVC = new TaskListViewController()
			@taskListVC.addTaskCard.addDelegate = @
			@taskListVC.taskList.enableDragAndDrop = true
			@taskListVC.taskHandler.listSortAttribute = "order"
			@taskListVC.taskHandler.delegate = @

		render: ->
			$("#main").html(@$el)
			@$el.html @taskListVC.el
			
		
		
		open: (options) ->
			@render()
			@load()
		load: ->
			
			swipy.topbarVC.setMainTitleAndEnableProgress("My Tasks", false )
			@taskListVC.addTaskCard.setPlaceHolder("Add Personal Task")
			# https://github.com/anthonyshort/backbone.collectionsubset
			@collectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					if !task.get("completionDate") and !task.isSubtask()
						if task.get("toUserId") is Parse.User.current().id or task.get("isAssignedToMe")
							return true
					return false
			})
			@taskListVC.taskHandler.loadCollection(@collectionSubset.child)
			@taskListVC.render()
		destroy: ->

		###
			AddTaskCard Delegate
		###
		taskCardDidCreateTask: ( taskCard, title, options) ->
			options = {} if !options
			options.toUserId = Parse.User.current().id
			Backbone.trigger("create-task", title, options)
			Backbone.trigger("reload/taskhandler")