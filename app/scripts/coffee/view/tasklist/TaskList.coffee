###
	The TaskList Class - Intended to be UI only for rendering a tasklist.
	Has a datasource to provide it with task models
	Has a delegate to notify when drag/drop/click/other actions occur
###
define [
	"underscore"
	"js/view/tasklist/TaskSection"
	"js/view/tasklist/TaskCard"
	"js/handler/DragHandler"
	], (_, TaskSection, TaskCard, DragHandler) ->
	Backbone.View.extend
		className: "task-list"
		initialize: ->
			# Set HTML tempalte for our list
			@listenTo( Backbone, "reload/handler", @reload )
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
			@$el.html ""
			$(@targetSelector).html( @$el )

			taskSection = new TaskSection()
			#taskSection.setTitles("Left", "Right")
			taskSectionEl = taskSection.$el.find('.task-section-list')
			for task in @tasks
				taskCard = new TaskCard({model: task})
				if @taskDelegate?
					taskCard.taskDelegate = @taskDelegate
				taskCard.render()
				taskSectionEl.append( taskCard.el )
			@$el.append taskSection.el
			

			if @enableDragAndDrop and @tasks.length > 0
				if !@dragDelegate?
					throw new Error("TaskList must have dragDelegate to enable Drag & Drop")
				if !@dragHandler?
					@dragHandler = new DragHandler()
					@dragHandler.delegate = @dragDelegate
				@dragHandler.createDragAndDropElements(".task-item:not(.add-task-card)")

		
		customCleanUp: ->
		cleanUp: ->
			# A hook for the subviews to do custom clean ups
			@customCleanUp()
			@stopListening()