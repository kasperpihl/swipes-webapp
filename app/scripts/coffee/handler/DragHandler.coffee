###

###

define ["underscore", "gsap", "gsap-draggable"], (_) ->
	class DragHandler
		###
			Drag and drop functionality: 
		###
		createDragAndDropElements: (selector) ->
			if !@delegate?
				throw new Error("DragHandler must have delegate")
			if !_.isFunction(@delegate.dragHandlerDidHit)
				throw new Error("DragHandler delegate must implement dragHandlerDidHit")
			dragOpts =
				type: "top,left"
				bounds: $(".total-container")
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
					if @pointerEvent.path?
						for el in @pointerEvent.path
							$el = $(el)
							if $el.hasClass("task-item")
								self.draggingId = "#" + $el.attr("id")
					else if @pointerEvent.originalTarget?
						currentTarget = @pointerEvent.originalTarget
						for num in [1..10]
							if currentTarget? and currentTarget
								if _.indexOf(currentTarget.classList, "task-item") isnt -1
									self.draggingId = "#" + currentTarget.id
								else
									currentTarget = currentTarget.parentNode
							else
								break
					self.updateMousePointer(@pointerEvent)
					$(".drag-mouse-pointer").addClass("shown")
					if self.delegate? and _.isFunction(self.delegate.extraIdsForDragging)
						self.extraClasses = self.delegate.extraIdsForDragging( self, self.draggingId )

				onDrag: (self) ->
					hit = self.hitTest( @pointerEvent )
					self.updateMousePointer(@pointerEvent)
					self.handleHitHover(hit)

				onDragEnd: (self) ->
					hit = self.hitTest(@pointerEvent)
					self.handleHitFinish(hit)
					self.draggingId = false

			Draggable.create(selector, dragOpts)
		# Used to update the position of the mouse pointer that follows the mouse when dragging
		updateMousePointer: (e) ->
			$(".drag-mouse-pointer").css({top: (e.pageY-20)+"px", left: (e.pageX + 15)+"px"})
		cleanDragAndDropElements: ->
			$(".drag-hover-entering").removeClass("drag-hover-entering")
			$(".task-list").find(".insert-seperator").remove()

		hitTest: (e) ->
			hit = {}
			hit.pointerEvent = e
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
					targetIdentifier = "#"+id
					if Draggable.hitTest(e, targetIdentifier, 0)
						return hit if targetIdentifier is @draggingId
						
						$hit = $(targetIdentifier)
						sensitivityThreshold = 15 #$("#task-" + id).height()/2

						if e.clientY <= ($hit.offset().top + sensitivityThreshold)
							hit.position = "top"
						else if e.clientY >= ($hit.offset().top + $hit.outerHeight() - sensitivityThreshold)
							hit.position = "bottom"
						else if e.clientY >= $hit.offset().top and e.clientY <= ($hit.offset().top + $hit.outerHeight())
							hit.position = "middle"

						hit.target = "#" + id
						hit.type = "task"
			@lastY = e.clientY
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
			console.log "hit finish"
			# Notify delegate about final hit
			callback = () ->
				$(".drag-hover-moving-item").removeClass("drag-hover-moving-item")
			@cleanDragAndDropElements()
			$(".drag-mouse-pointer").removeClass("shown")
			if hit? and @delegate? and _.isFunction(@delegate.dragHandlerDidHit)
				willCallback = @delegate.dragHandlerDidHit( @ , @draggingId, hit, callback)
				if !willCallback
					callback()
			else
				callback()