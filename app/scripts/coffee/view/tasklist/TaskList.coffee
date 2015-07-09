###
	The TaskList Class - Intended to be UI only for rendering a tasklist.
	Has a datasource to provide it with task models
	Has a delegate to notify when drag/drop/click/other actions occur
###
define [
	"underscore"
	"text!templates/tasklist/task-section.html"
	"text!templates/tasklist/task.html"
	"js/handler/DragHandler"
	], (_, TaskSectionTmpl, TaskTmpl, DragHandler) ->
	Backbone.View.extend
		initialize: ->
			# Set HTML tempalte for our list
			@taskSectionTemplate = _.template TaskSectionTmpl
			@taskTemplate = _.template TaskTmpl
			@listenTo( Backbone, "closed-window", @handleHitFinish )
		remove: ->
			@cleanUp()
			@$el.empty()

		
		# Reload datasource for 
		reload: ->
			if @dataSource? and _.isFunction(@dataSource.tasksForTaskList)
				@tasks = @dataSource.tasksForTaskList( @ )
				@render()
			else
				throw new Error("TaskList must have dataSource with defined tasksForTaskList method")
	


		render: ->
			if !@targetSelector?
				throw new Error("TaskList must have targetSelector to render")

			@$el.html @taskSectionTemplate( tasks: @tasks, taskTmpl: @taskTemplate )
			$(@targetSelector).html( @$el )
			if @enableDragAndDrop
				if !@dragDropDelegate?
					throw new Error("TaskList must have dragDropDelegate to enable Drag & Drop")
				if !@dragHandler?
					@dragHandler = new DragHandler()
					@dragHandler.delegate = @dragDropDelegate
				@dragHandler.createDragAndDropElements(".task-item:not(.add-task-card)")

		
		customCleanUp: ->
		cleanUp: ->
			# A hook for the subviews to do custom clean ups
			@customCleanUp()
			@stopListening()