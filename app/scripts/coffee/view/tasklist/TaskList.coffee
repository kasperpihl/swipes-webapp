###
	The TaskList Class - Intended to be UI only for rendering a tasklist.
	Has a datasource to provide it with task models
	Has a delegate to notify when drag/drop/click/other actions occur
###
define [
	"underscore"
	"js/view/modules/Section"
	"js/view/tasklist/TaskCard"
	"js/handler/DragHandler"
	], (_, Section, TaskCard, DragHandler) ->
	Backbone.View.extend
		className: "task-list"
		initialize: ->
			# Set HTML tempalte for our list
			@listenTo( Backbone, "reload/taskhandler", @render )
			@numberOfSections = 0
		remove: ->
			@cleanUp()
			@$el.empty()

		
		# Reload datasource for 

		render: ->
			if !@dataSource?
				throw new Error("TaskList must have dataSource")
			if !_.isFunction(@dataSource.taskListDataForSection)
				throw new Error("TaskList dataSource must implement taskListDataForSection")

			if !@targetSelector?
				throw new Error("TaskList must have targetSelector to render")
			
			@$el.html ""
			$(@targetSelector).html( @$el )


			numberOfSections = 1
			numberOfTasks = 0
			
			if _.isFunction(@dataSource.taskListNumberOfSections)
				numberOfSections = @dataSource.taskListNumberOfSections( @ )
			@_taskCardsById = {}
			for section in [1 .. numberOfSections]
				

				# Load tasks and titles for section
				sectionData = @dataSource.taskListDataForSection( @, section )

				# Instantiate 
				section = new Section()
				section.setTitles(sectionData.leftTitle, sectionData.rightTitle)
				sectionEl = section.$el.find('.section-list')

				for task in sectionData.tasks
					numberOfTasks++
					taskCard = new TaskCard({model: task})
					if @taskDelegate?
						taskCard.taskDelegate = @taskDelegate
					if sectionData.showSource?
						taskCard.showSource = true
					if sectionData.showSchedule
						taskCard.showSchedule = true

					taskCard.render()
					@_taskCardsById[task.id] = taskCard
					sectionEl.append( taskCard.el )
				@$el.append section.el


			if @enableDragAndDrop and numberOfTasks > 0
				if !@dragDelegate?
					throw new Error("TaskList must have dragDelegate to enable Drag & Drop")
				if !@dragHandler?
					@dragHandler = new DragHandler()
					@dragHandler.delegate = @dragDelegate
				@dragHandler.createDragAndDropElements(".task-item:not(.add-task-card)")
		taskCardById: (identifier) ->
			return @_taskCardsById?[identifier]
		customCleanUp: ->
		cleanUp: ->
			@dragDelegate = null
			@dataSource = null
			@delegate = null
			@taskDelegate = null

			# A hook for the subviews to do custom clean ups
			@customCleanUp()
			@stopListening()