###
	The TaskList Class - Intended to be UI only for rendering a tasklist.
	Has a datasource to provide it with task models
	Has a delegate to notify when drag/drop/click/other actions occur
###
define [
	"underscore"
	"js/view/modules/Section"
	"js/view/tasklist/TaskCard"
	"js/view/tasklist/ActionRow"
	"js/handler/DragHandler"
	], (_, Section, TaskCard, ActionRow, DragHandler) ->
	Backbone.View.extend
		className: "task-list"
		initialize: ->
			# Set HTML template for our list
			@listenTo( Backbone, "reload/taskhandler", @render )

			@numberOfSections = 0
			@toggleCompleted = false
		remove: ->
			@cleanUp()
			@$el.empty()
		setActionList: ->
			@className = "action-list"
			@actionList = true

		# Reload datasource for

		render: (e) ->
			if !@dataSource?
				throw new Error("TaskList must have dataSource")
			if !_.isFunction(@dataSource.taskListDataForSection)
				throw new Error("TaskList dataSource must implement taskListDataForSection")

			if !@targetSelector?
				throw new Error("TaskList must have targetSelector to render")

			if e and e.hasOwnProperty('checked')
				@toggleCompleted = e.checked

			numberOfSections = 1
			numberOfTasks = 0

			if @titles?
				emptyTitles = if !@toggleCompleted then @titles.current else @titles.completed

			@$el.html ""
			$(@targetSelector).html( @$el )

			if _.isFunction(@dataSource.taskListNumberOfSections)
				numberOfSections = @dataSource.taskListNumberOfSections( @ )

			@_taskCardsById = {}
			realNumSections = 0
			for section in [1 .. numberOfSections]
				# Load tasks and titles for section
				sectionData = @dataSource.taskListDataForSection( @, section )

				continue if !sectionData
				realNumSections++
				# Instantiate
				section = new Section()
				if sectionData.expandClass
					section.expandClass = sectionData.expandClass
				section.setTitles(sectionData.leftTitle, sectionData.rightTitle)
				sectionEl = section.$el.find('.section-list')

				if lastLeftTitle and lastLeftTitle is "Your current tasks"
					section.$el.find('.section-header').css("marginTop","150px")

				for task in sectionData.tasks
					numberOfTasks++

					if @actionList
						taskEl = new ActionRow({model: task})
					else
						taskEl = new TaskCard({model: task})

					if @taskDelegate?
						taskEl.taskDelegate = @taskDelegate
					if sectionData.showSource?
						taskEl.showSource = true
					if sectionData.showSchedule
						taskEl.showSchedule = true

					taskEl.render()
					@_taskCardsById[task.id] = taskEl
					sectionEl.append taskEl.el
				@$el.append section.el
				lastLeftTitle = sectionData.leftTitle

			if numberOfTasks is 0 and emptyTitles and emptyTitles.emptyTitle
				@$el.prepend("<div class=\"empty-text\"><h4 class=\"title\">" + emptyTitles.emptyTitle + "</h4></div>")
				if emptyTitles.emptySubtitle
					@$el.find(".empty-text").append("<div class=\"subtitle\">"+ emptyTitles.emptySubtitle + "</div>")
				if emptyTitles.emptyDescription
					@$el.find(".empty-text").append("<div class=\"description\">"+ emptyTitles.emptyDescription+"</div>")

			Backbone.trigger("update/numberOfTasks", numberOfTasks)

			if @enableDragAndDrop and numberOfTasks > 0
				if !@dragDelegate?
					throw new Error("TaskList must have dragDelegate to enable Drag & Drop")
				if !@dragHandler?
					@dragHandler = new DragHandler()
					@dragHandler.delegate = @dragDelegate
				console.log "adding drag drop"
				if @actionList
					@dragHandler.createDragAndDropElements(".action-item:not(.add-action-container)")
				else
					@dragHandler.createDragAndDropElements(".task-item:not(.add-task-card-container) .main-info-container")
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
