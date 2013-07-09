define ['hammer'], (Hammer) ->
	Backbone.View.extend
		initialize: ->
			_.bindAll @
			
			@content = @$el.find('.todo-content')
			
			@render()
		enableGestures: ->
			@hammer = Hammer(@content[0]).on "drag", @handleDrag
			@hammer = Hammer(@content[0]).on "dragend", @handleDragEnd
		disableGestures: ->
			log "Disabling gestures for ", @model.toJSON()
		getUserIntent: (val) ->
			dragAmount = val / window.innerWidth
			absDragAmount = Math.abs dragAmount
			
			name = if dragAmount > 0 then "done" else "prostpone"

			return { name: name, amount: absDragAmount }
		handleDrag: (e) ->
			# Figure out if we are draggin left or right
			val = if e.gesture.direction is "left" then e.gesture.distance * -1 else e.gesture.distance

			@intent = @getUserIntent val
			switch @intent.name
				when "done"
					@$el.css "background", "hsla(144, 40%, 47%, #{@intent.amount * 4})"
					break
				when "prostpone"
					@$el.css "background", "hsla(43, 78%, 44%, #{@intent.amount * 4})"
					break

			@content.css "-webkit-transform", "translate3d(#{val}px, 0, 0)"
		handleDragEnd: (e) ->
			if @intent.amount < 0.2
				@content.css 
					"-webkit-transform": "translate3d(0, 0, 0)"
					"background": ""
				return

			switch @intent.name
				when "done"
					@$el.addClass "done"
					alert "done!"
					break
				when "prostpone"
					@$el.addClass "prostponed"
					alert "prostponed"
					break
			
		render: ->
			@enableGestures()
			return @el
		remove: ->
			@destroy()
		destroy: ->
			@disableGestures()

