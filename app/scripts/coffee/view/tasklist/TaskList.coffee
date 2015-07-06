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
			@render()
		remove: ->
			@cleanUp()
			@$el.empty()
		render: ->
			@tempTasks = [
				{ title: "Design mockup", id:"akrn3" }
				{ title: "Test Android version", id: "algs" }
				{ title: "Prepare pitchdeck", id:"llkfs" }
				{ title: "Pack luggage for vacation", id:"fdid" }
				{ title: "Check non-fiction books for reading", id:"peie" }
				{ title: "Develop smart drag-n-drop", id:"psjwo" }
			]
			$("#main").html( @taskSectionTemplate( tasks: @tempTasks, taskTmpl: @taskTemplate ))
			self = @
			dragOpts =
				type: "top,left"
				bounds: $(".container")
				autoScroll:1
				# Throwing / Dragging
				throwProps: no
				edgeResistance: 0.8
				maxDuration: 0.4
				onDragParams: [ @ ]
				onDragEndParams: [ @ ]
				# Handlers
				onDragStart: (e) ->
					console.log e
					for el in e.path
						$el = $(el)
						if $el.hasClass("task-item")
							self.draggingId = "#" + $el.attr("id")
							$el.addClass("drag-hover-moving-item")
				onDrag: (self) ->
					hit = self.hitTest( @pointerEvent )
					self.handleHitHover(hit)
					
					#console.log e.x
				onDragEnd: (self) ->
					$(".drag-hover-moving-item").removeClass("drag-hover-moving-item")
					self.draggingId = false
					hit = self.hitTest(@pointerEvent)
					self.handleHitFinish(hit)

			Draggable.create(".task-item", dragOpts)
		cleanDragAndDropElements: ->
			$(".drag-hover-entering").removeClass("drag-hover-entering")
			$(".task-list").find(".insert-seperator").remove()

		customCleanUp: ->
		cleanUp: ->
			# A hook for the subviews to do custom clean ups
			@customCleanUp()

		hitTest: (e) ->
			hit = {}
			if Draggable.hitTest(e, "#sidebar-members-list", 0)
				hit.parent = "#sidebar-members-list"

			if Draggable.hitTest(e, "#sidebar-project-list", 0)
				hit.parent = "#sidebar-project-list"
			
			if Draggable.hitTest(e, ".task-list", 0)
				hit.parent = ".task-list"

				ids = $.map( $(".task-list .task-item"), (o) -> o["id"] ) #_.pluck(@tempTasks, "id")
				for i, id of ids

					if Draggable.hitTest(e, "#" + id, 0)
						hit.target = "#" + id
						if e.y isnt @lastY and hit.target isnt @draggingId
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
		handleHitFinish: (hit) ->
			if hit? and hit
				if hit.parent is ".task-list"
					if hit.target and hit.position
						if hit.position is "top"
							console.log "top"
						else if hit.position is "bottom"
							console.log "bottom"
						else if hit.position is "middle"
							console.log "middle"
		handleHitHover: (hit) ->
			isSame = true if self.lastHit
			#console.log hit
			for key, val of self.lastHit
				console.log key, val, hit?[key]
				if !hit or hit and hit[key] isnt val
					isSame = false
			console.log "same" if isSame
			return if isSame

			if !hit or !Object.keys(hit).length
				@cleanDragAndDropElements()

			else if hit? and hit
				if hit.parent is ".task-list"
					if hit.target and hit.position
						$hit = $(hit.target)
						if hit.position is "top"
							if(!$hit.prev().hasClass("insert-seperator"))
								@cleanDragAndDropElements()
								$hit.before("<li class=\"insert-seperator\"></li>")
						else if hit.position is "bottom"
							if(!$hit.next().hasClass("insert-seperator"))
								@cleanDragAndDropElements()
								$hit.after("<li class=\"insert-seperator\"></li>")
						else if hit.position is "middle"
							@cleanDragAndDropElements()
							$hit.addClass("drag-hover-entering")
			@lastHit = hit

		onDrag: (e) ->