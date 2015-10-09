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
		events:
			"click #import-asana": "importAsana"
		initialize: (options) ->
			@options = options
			channelVC = @options.delegate
			isMyTasks = @options.isMyTasksView
			startImportFromAsana = swipy.startImportFromAsana

			@setTemplate()

			@addTaskCard = new AddTaskCard()
			@addTaskCard.addDelegate = channelVC

			#@toggleCompletedTasks = new ToggleCompletedTasks
				#targetSelector: '.task-list-view-controller .toggle-completed-tasks-container'

			@taskHandler = new TaskHandler()
			@taskHandler.delegate = channelVC
			@taskHandler.listSortAttribute = if isMyTasks then "order" else "projectOrder"
			@taskHandler.isMyTasks = isMyTasks
			@taskHandler.loadCollection(options.collectionToLoad)

			@taskList = new TaskList()
			@taskList.targetSelector = ".task-list-view-controller .task-list-container"
			@taskList.enableDragAndDrop = true

			if isMyTasks
				@taskList.showSource = true

			# Settings the Task Handler to receive actions from the task list
			@taskList.taskDelegate = @taskHandler
			@taskList.dragDelegate = @taskHandler
			@taskList.dataSource = @taskHandler
			_.bindAll(@, "editTaskDidClickBack")
			Backbone.on( "request-work-task", @requestWorkTask, @ )
			Backbone.on( "edit/task", @editTask, @ )

			@setEmptyTitles()

			if startImportFromAsana
				swipy.startImportFromAsana = false
				@startImportFromAsana()
		showThreadOverlay: (show) ->
			console.log "showing thread", show
		editTask: (model) ->
			if model
				@editTaskView = new EditTask({model: model})
				@editModel = model
				@editTaskView.delegate = @
				@editTaskView.render()
				@isEditing = true
				@$el.find(".edit-task-container").html @editTaskView.el
				@$el.addClass("editMode")
			else
				@editModel = null
				@editTaskView?.remove()
				@isEditing = false
				@$el.removeClass("editMode")
				@taskHandler?.bouncedReloadWithEvent()
			Backbone.trigger("tasklistvc/edited-task")
		goBackFromEditMode: ->
			currRoute = Backbone.history.fragment
			indexOfTask = currRoute.indexOf("/task")

			if indexOfTask isnt -1
				newRoute = currRoute.substring(0, indexOfTask)

			indexOfTasks = currRoute.indexOf("tasks")
			if indexOfTasks is 0
				newRoute = "tasks"
			if newRoute
				swipy.router.navigate(newRoute, {trigger: false})
				swipy.router.history.push(newRoute)
			@editTask(false)
		editTaskDidClickBack: (editTask) ->
			@goBackFromEditMode()

		setTemplate: ->
			@template = _.template Template
		render: ->
			@$el.html @template({})

			@addTaskCard.render()
			@$el.find('.add-task-container').prepend( @addTaskCard.el )

			#@toggleCompletedTasks.render()
			@taskList.render()
		scrollToTop: ->
			@$el.find(".scroller").scrollTop(0)
		requestWorkTask: ( task ) ->
			@workEditor = new RequestWorkOverlay( model: task )
		setEmptyTitles: () ->
			channelVC = @options.delegate
			isMyTasks = @options.isMyTasksView
			titles = {}

			if isMyTasks
				titles =
					current:
						emptyTitle: "No tasks in your workspace"
						emptySubtitle: "You can add Private tasks below or assign tasks from channels and groups."
						emptyDescription: "Tasks here is the ones assigned to you. Here you can get an overview of your commitments and put it all in order."
					completed:
						emptyTitle: "No completed tasks in your workspace"
						emptySubtitle: "You can add Private tasks below or assign tasks from channels and groups."
						emptyDescription: "Tasks here is the ones assigned to you. Here you can get an overview of your commitments and put it all in order."

				@addTaskCard.setPlaceHolder("Add a new private task")
			else if channelVC.currentUser?
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
		importAsana: ->
			swipy.api.callAPI "asana/asanaToken", "POST", {}, (res, error) ->
				if res && res.redirect
					window.location = res.redirect
		startImportFromAsana: ->
			swipy.api.callAPI "asana/import", "POST", {}, (res, error) ->
				if res
					console.log 'done'
		destroy: ->
			Backbone.off(null,null, @)
			@addTaskCard?.destroy?()
			@editModel = null
			@taskHandler?.destroy?()
			#@toggleCompletedTasks?.destroy?()
			@taskList?.remove?()
			@editTaskView?.remove()
			@remove()
