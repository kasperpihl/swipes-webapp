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
			@listenTo( Backbone, "reload/handler", @render )
			@numberOfSections = 0
		remove: ->
			@cleanUp()
			@$el.empty()

		
		# Reload datasource for 

		render: ->
			if !@dataSource?
				throw new Error("TaskList must have dataSource")
			if !_.isFunction(@dataSource.taskListTasksForSection)
				throw new Error("TaskList dataSource must implement taskListTasksForSection")

			if !@targetSelector?
				throw new Error("TaskList must have targetSelector to render")
			
			@$el.html ""
			$(@targetSelector).html( @$el )


			numberOfSections = 1
			numberOfTasks = 0
			
			if _.isFunction(@dataSource.taskListNumberOfSections)
				numberOfSections = @dataSource.taskListNumberOfSections( @ )
			
			for section in [1 .. numberOfSections]
				

				# Load tasks and titles for section
				if _.isFunction(@dataSource.taskListLeftTitleForSection)
					leftTitle = @dataSource.taskListLeftTitleForSection( @, section )
				if _.isFunction(@dataSource.taskListRightTitleForSection)
					rightTitle = @dataSource.taskListRightTitleForSection( @, section )
				tasksInSection = @dataSource.taskListTasksForSection( @, section )
				

				# Instantiate 
				taskSection = new TaskSection()
				taskSection.setTitles(leftTitle, rightTitle)
				taskSectionEl = taskSection.$el.find('.task-section-list')

				for task in tasksInSection
					numberOfTasks++
					taskCard = new TaskCard({model: task})
					if @taskDelegate?
						taskCard.taskDelegate = @taskDelegate
					taskCard.render()
					taskSectionEl.append( taskCard.el )
				@$el.append taskSection.el


			if @enableDragAndDrop and numberOfTasks > 0
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