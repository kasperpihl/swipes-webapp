define [
	"underscore"
	"text!templates/viewcontroller/task-list-view-controller.html"
	"js/view/tasklist/ToggleCompletedTasks"
	"js/view/tasklist/TaskList"
	"js/view/tasklist/AddTaskCard"
	"js/handler/TaskHandler"
	"js/view/tasklist/EditTask"
	"js/view/workmode/RequestWorkOverlay"
	], (_, Template, ToggleCompletedTasks, TaskList, AddTaskCard, TaskHandler, EditTask, RequestWorkOverlay) ->
	Backbone.View.extend
		className: "task-list-view-controller"
		initialize: (options) ->
			@options = options

			@setTemplate()
			@addTaskCard = new AddTaskCard()
			@addTaskCard.addDelegate = options.delegate

			@toggleCompletedTasks = new ToggleCompletedTasks
				targetSelector: '.task-list-view-controller .toggle-completed-tasks-container'

			@taskList = new TaskList()
			@taskList.targetSelector = ".task-list-view-controller .task-list-container"
			@taskList.enableDragAndDrop = true
			
			@taskHandler = new TaskHandler()
			@taskHandler.listSortAttribute = "projectOrder"
			@taskHandler.delegate = options.delegate

			# Settings the Task Handler to receive actions from the task list
			@taskList.taskDelegate = @taskHandler
			@taskList.dragDelegate = @taskHandler
			@taskList.dataSource = @taskHandler
			Backbone.on( "request-work-task", @requestWorkTask, @ )
			Backbone.on( "edit/task", @editTask, @ )

			@setEmptyTitles()
			@loadCollectionSubset()
		editTask: (model) ->
			return
			taskCard = @taskList.taskCardById(model.id)
			return if !taskCard
			@editTask = new EditTask({model: model})
			@editTask.render()
			taskCard.$el.find(".expanding").html @editTask.el
			@editTask.loadTarget($(".nav-item.actionTab"))
			taskCard.$el.addClass("editMode")
		setTemplate: ->
			@template = _.template Template
		render: ->
			@$el.html @template({})
			@addTaskCard.render()
			@$el.find('.add-task-container').prepend( @addTaskCard.el )
			@toggleCompletedTasks.render()
			@taskList.render()
		requestWorkTask: ( task ) ->
			@workEditor = new RequestWorkOverlay( model: task )
		setEmptyTitles: () ->
			channelVC = @options.delegate
			titles = {}

			if channelVC.currentUser?
				if channelVC.currentUser.get("name") isnt "slackbot"
					titles =
						current:
							emptyTitle: "No Direct Tasks between you & " + channelVC.currentUser.get("name")
							emptySubtitle: "You can add them below or you can drag a message to here."
							emptyDescription: "Tasks here will only be visible between you and " + channelVC.currentUser.get("name") + ". You can assign tasks to either you or " + channelVC.currentUser.get("name") + " and it will be sent into your workspaces."
						completed:
							emptyTitle: "No Completed Tasks between you & " + channelVC.currentUser.get("name")
							emptyDescription: "Tasks here will only be visible between you and " + channelVC.currentUser.get("name") + ". You can assign tasks to either you or " + channelVC.currentUser.get("name") + " and it will be sent into your workspaces."

					@addTaskCard.setPlaceHolder("Add a new task between you & " + channelVC.currentUser.get("name"))
				else
					titles = 
						current:
							emptyTitle: "No Direct Tasks between you, slackbot & s.o.f.i."
							emptyDescription: "Tasks here will only be visible between you, slackbot & s.o.f.i. You can assign tasks to you or slackbot, but he probably won't do them!"
						completed:
							emptyTitle: "No Completed Tasks between you, slackbot & s.o.f.i."
							emptyDescription: "Tasks here will only be visible between you, slackbot & s.o.f.i. You can assign tasks to you or slackbot, but he probably won't do them!"

					@addTaskCard.setPlaceHolder("Add a new task between you, slackbot & s.o.f.i.")
			else
				isGroup = channelVC.currentList.get("is_group")
				channelLabel = if isGroup then "group" else "channel"
				hashLabel = if isGroup then "" else "# "
				titles =
					current:
						emptyTitle: "No tasks in " + hashLabel + channelVC.currentList.get("name")
						emptySubtitle: "You can add new tasks below or simply drag a message here."
						emptyDescription: "When you add tasks in this "+channelLabel+", they will be visible only to its members. You can assign tasks to them and they'll be sent to your teammates' personal workspaces."
					completed:
						emptyTitle: "No completed tasks in " + hashLabel + channelVC.currentList.get("name")
						emptyDescription: "When you add tasks in this "+channelLabel+", they will be visible only to its members. You can assign tasks to them and they'll be sent to your teammates' personal workspaces."

				@addTaskCard.setPlaceHolder("Add a new task to #" + channelVC.currentList.get("name"))

			@taskList.titles = titles
		loadCollectionSubset: () ->
			channelVC = @options.delegate

			# https://github.com/anthonyshort/backbone.collectionsubset
			projectId = channelVC.currentList.id
			channelVC.taskCollectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					return task.get("projectLocalId") is projectId and !task.isSubtask()
			})

			@taskHandler.loadCollection(channelVC.taskCollectionSubset.child)
		destroy: ->
			Backbone.off(null,null, @)
			@addTaskCard?.destroy?()
			@taskHandler?.destroy?()
			@toggleCompletedTasks?.destroy?()
			@taskList?.remove?()
			@remove()