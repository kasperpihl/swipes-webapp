###
	The TaskList Class - Intended to be UI only for rendering a tasklist.
	Has a datasource to provide it with task models
	Has a delegate to notify when drag/drop/click/other actions occur
###
define [
	"underscore"
	"text!templates/tasklist/task-section.html"
	"text!templates/tasklist/task.html"
	"gsap", 
	"gsap-draggable"
	], (_, TaskSectionTmpl, TaskTmpl) ->
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
			$(@targetSelector).html( @taskSectionTemplate( tasks: @tasks, taskTmpl: @taskTemplate ))
			if @enableDragAndDrop
				@createDragAndDropElements()


		
		customCleanUp: ->
		cleanUp: ->
			# A hook for the subviews to do custom clean ups
			@customCleanUp()
			@stopListening()





		###
			Drag and drop functionality: 
		###
		createDragAndDropElements: ->
			if !@delegate?
				throw new Error("delegate must be set on TaskList to enableDragAndDrop")
			if !_.isFunction(@delegate.taskListDidHitFromDrag)
				throw new Error("delegate must implement taskListDidHitFromDrag to drag&drop")
			dragOpts =
				type: "top,left"
				bounds: $(".container")
				autoScroll:1
				# Throwing / Dragging
				throwProps: no
				edgeResistance: 0.8
				maxDuration: 0.4
				onDragStartParams: [ @ ]
				onDragParams: [ @ ]
				onDragEndParams: [ @ ]
				# Handlers
				onDragStart: (self) ->
					for el in @pointerEvent.path
						$el = $(el)
						if $el.hasClass("task-item")
							self.updateMousePointer(@pointerEvent)
							$(".drag-mouse-pointer").addClass("shown")
							self.draggingId = "#" + $el.attr("id")
							$el.addClass("drag-hover-moving-item")
				onDrag: (self) ->
					hit = self.hitTest( @pointerEvent )
					self.updateMousePointer(@pointerEvent)
					self.handleHitHover(hit)
					
					#console.log e.x
				onDragEnd: (self) ->
					
					hit = self.hitTest(@pointerEvent)
					self.handleHitFinish(hit)
					self.draggingId = false

			Draggable.create(".task-item:not(.add-task-card)", dragOpts)
		updateMousePointer: (e) ->
			$(".drag-mouse-pointer").css({top: (e.pageY-20)+"px", left: (e.pageX + 15)+"px"})
		cleanDragAndDropElements: ->
			$(".drag-hover-entering").removeClass("drag-hover-entering")
			$(".task-list").find(".insert-seperator").remove()

		hitTest: (e) ->
			hit = {}

			if Draggable.hitTest(e, "#sidebar-my-tasks", 0)
				hit.parent = "#sidebar-members-list"
				ids = $.map( $("#sidebar-my-tasks .tasks > li"), (o) -> o["id"] )
				for i, id of ids
					if Draggable.hitTest(e, "#" + id, 0)
						hit.target = "#" + id
						hit.type = "mytask"
						hit.position = "middle"


			if Draggable.hitTest(e, "#sidebar-members-list", 0)
				hit.parent = "#sidebar-members-list"
				ids = $.map( $("#sidebar-members-list .team-members > li"), (o) -> o["id"] )
				for i, id of ids
					if Draggable.hitTest(e, "#" + id, 0)
						hit.target = "#" + id
						hit.type = "member"
						hit.position = "middle"


			if Draggable.hitTest(e, "#sidebar-project-list", 0)
				hit.parent = "#sidebar-project-list"
				ids = $.map( $("#sidebar-project-list .projects > li"), (o) -> o["id"] )
				for i, id of ids
					if Draggable.hitTest(e, "#" + id, 0)
						hit.target = "#" + id
						hit.type = "project"
						hit.position = "middle"


			if Draggable.hitTest(e, ".task-list", 0)
				hit.parent = ".task-list"

				ids = $.map( $(".task-list .task-item"), (o) -> o["id"] ) #_.pluck(@tempTasks, "id")
				for i, id of ids

					if Draggable.hitTest(e, "#" + id, 0)
						return hit if "#"+id is @draggingId
						hit.target = "#" + id
						hit.type = "task"
						
						$hit = $(hit.target)
						sensitivityThreshold = 15 #$("#task-" + id).height()/2

						if e.y <= ($hit.offset().top + sensitivityThreshold)
							hit.position = "top"
						else if e.y >= ($hit.offset().top + $hit.height() - sensitivityThreshold)
							hit.position = "bottom"
						else if e.y > $hit.offset().top and e.y < ($hit.offset().top + $hit.height())
							hit.position = "middle"
			@lastY = e.y
			return hit
	
		handleHitHover: (hit) ->
			# Check if hit is the same to minimise dom manipulation
			if self.lastHit
				isSame = true 
				for key, val of self.lastHit
					if !hit or hit and hit[key] isnt val
						isSame = false
				return if isSame
			
			# Check if empty hit and make sure to clear help elements
			if !hit or hit? and !Object.keys(hit).length
				@cleanDragAndDropElements()
				hit = null


			else if hit? and hit
				if hit.position is "middle"
					$hit = $(hit.target)
					@cleanDragAndDropElements()
					$hit.addClass("drag-hover-entering")

				if hit.parent is ".task-list"
					if hit.target and hit.position
						$hit = $(hit.target)
						if hit.position is "top"
							if !$hit.prev().hasClass("insert-seperator")
								@cleanDragAndDropElements()
								$hit.before("<li class=\"insert-seperator\"><div></div></li>")
						else if hit.position is "bottom"
							if !$hit.next().hasClass("insert-seperator")
								@cleanDragAndDropElements()
								$hit.after("<li class=\"insert-seperator\"><div></div></li>")
					else @cleanDragAndDropElements()
			@lastHit = hit
		handleHitFinish: (hit) ->
			# Notify delegate about final hit
			if hit? and _.isFunction(@delegate.taskListDidHitFromDrag)
				@delegate.taskListDidHitFromDrag( @ , @draggingId, hit)

			@cleanDragAndDropElements()
			$(".drag-mouse-pointer").removeClass("shown")
			$(".drag-hover-moving-item").removeClass("drag-hover-moving-item")