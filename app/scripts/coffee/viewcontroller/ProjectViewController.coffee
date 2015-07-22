define [
	"underscore"
	"gsap"
	"js/viewcontroller/TaskListViewController"
	], (_, TweenLite, TaskListViewController) ->
	Backbone.View.extend
		className: "project-view-controller"
		initialize: ->
			@taskListVC = new TaskListViewController()
			@taskListVC.addTaskCard.addDelegate = @
			@taskListVC.taskList.enableDragAndDrop = true
			@taskListVC.taskHandler.listSortAttribute = "projectOrder"
			
		render: ->
			$("#main").html(@$el)
			@$el.html @taskListVC.el
			@taskListVC.render()
			
		open: (options) ->
			@projectId = options.id
			swipy.rightSidebarVC.sidebarDelegate = @
			@render()
			@loadProject(@projectId)
		loadProject: (projectId) ->
			
			@currentProject = swipy.collections.projects.get(projectId)
			
			swipy.topbarVC.setMainTitleAndEnableProgress(@currentProject.get("name"),false)

			# https://github.com/anthonyshort/backbone.collectionsubset
			@collectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					return task.get("projectLocalId") is projectId and !task.get("completionDate") and !task.isSubtask()
			})
			
			@taskListVC.taskHandler.loadCollection(@collectionSubset.child)
			@taskListVC.taskList.render()

			#swipy.rightSidebarVC.loadWindow(@el)
		destroy: ->

		###
			RightSidebarDelegate
		###
		sidebarClickedMenuButton: (sidebar, e) ->


		###
			AddTaskCard Delegate
		###
		taskCardDidCreateTask: ( taskCard, title, options) ->
			options = {} if !options
			options.projectLocalId = @projectId
			options.ownerId = @currentProject.get("ownerId")
			Backbone.trigger("create-task", title, options)
			@taskListVC.taskList.render()