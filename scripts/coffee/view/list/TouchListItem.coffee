define ["view/list/BaseListItem", 'hammer'], (BaseListItemView, Hammer) ->
	BaseListItemView.extend
		enableInteraction: ->
			@hammer = Hammer(@content[0]).on "drag", @handleDrag
			@hammer = Hammer(@content[0]).on "dragend", @handleDragEnd
		disableInteraction: ->
			console.warn "Disabling touch gestures for ", @model.toJSON()
		getUserIntent: (val) ->
			dragAmount = val / window.innerWidth
			absDragAmount = Math.abs dragAmount
			
			name = if dragAmount > 0 then "completed" else "scheduled"

			return { name: name, amount: absDragAmount }
		handleDrag: (e) ->
			# Figure out if we are draggin left or right
			val = if e.gesture.direction is "left" then e.gesture.distance * -1 else e.gesture.distance

			@intent = @getUserIntent val
			switch @intent.name
				when "completed"
					@$el.css "background", "hsla(144, 40%, 47%, #{@intent.amount * 4})"
					break
				when "scheduled"
					@$el.css "background", "hsla(43, 78%, 44%, #{@intent.amount * 4})"
					break

			@content.css "-webkit-transform", "translate3d(#{val}px, 0, 0)"
		handleDragEnd: (e) ->
			if @intent.amount < 0.2
				@content.css "-webkit-transform": "translate3d(0, 0, 0)", "background": ""
			else
				# Add transition and transition delay based on the amound of distance swiped
				delay = ( 1 - @intent.amount ) / 2
				@content.css 
					"-webkit-transition": "all #{delay}s ease-out"
					"-webkit-transform": ""
				
				@$el.addClass @intent.name
				
				setTimeout => 
						@$el.slideUp 200, => 
							@model.set("state", @intent.name)
							@model.save()
					, delay * 1000

