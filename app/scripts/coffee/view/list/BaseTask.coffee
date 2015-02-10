define ["underscore", "backbone", "gsap", "timelinelite", "text!templates/task.html"], (_, Backbone, TweenLite, TimelineLite, TaskTmpl) ->
	Backbone.View.extend
		tagName: "li"
		initialize: ->
			_.bindAll( @, "onSelected", "setBounds", "toggleSelected", "togglePriority", "edit", "handleAction" )

			# Bind events that should re-render the view
			@listenTo( @model, "change:tags change:timeStr", @render, @ )

			@listenTo( @model, "change:selected", @onSelected )
			$(window).on "resize", @setBounds

			@setTemplate()
			@init()
			@render()
			
			@bindEvents()
		bindEvents: ->
			# Bind all events manually, so events extending me can use the
			# events hash freely
			@$el.on( "click", ".todo-content", @toggleSelected )
			@$el.on( "click", ".priority", @togglePriority )
			@$el.on( "dblclick", ".todo-content", @edit )
			@$el.on( "click", ".actions a", @handleAction )
		setTemplate: ->
			@template = _.template TaskTmpl
		setBounds: ->
			@bounds = @el.getClientRects()[0]
		init: -> # Hook for views extending me
		toggleSelected: ->
			currentlySelected = @model.get( "selected" ) or false
			@model.set( "selected", !currentlySelected )
			Backbone.trigger( "did-press-task", [@model])
			
		togglePriority: (e) ->
			e.stopPropagation()
			@model.togglePriority()
		handleAction: (e) ->
			# Actual trigger logic
			if $( e.currentTarget ).hasClass "schedule-button"
				Backbone.trigger( "schedule-task", @model )
			else if $( e.currentTarget ).hasClass "complete-button"
				Backbone.trigger( "complete-task", @model )
			else if $( e.currentTarget ).hasClass "todo-button"
				Backbone.trigger( "todo-task", @model )
		onSelected: (model, selected) ->
			@$el.toggleClass( "selected", selected )
		edit: (e) ->
			# Ignore doubleclicks on priority dot
			return false if e.target.className is "priority"

			# Else navigator to editor.
			identifier = if @model.id then @model.id else @model.get "tempId"
			swipy.router.navigate( "edit/#{ identifier }", yes )
		render: ->
			# If template isnt set yet, just return the empty element
			return @ unless @template?
			renderJSON = @model.toJSON()
			numberOfActionStepsLeft = 0
			if @model.get "subtasksLocal" 
				numberOfActionStepsLeft = @model.get("subtasksLocal").length
				for subtask in @model.get "subtasksLocal"
					if subtask.get "completionDate"
						numberOfActionStepsLeft--
			renderJSON.numberOfActionStepsLeft = numberOfActionStepsLeft

			@$el.html @template renderJSON
			@$el.attr( "data-id", @model.id )
			@afterRender()
			return @
		afterRender: ->
		remove: ->
			@cleanUp()
			@$el.remove()
		customCleanUp: ->
			# Hook for views extending me
		swipeRight: (className, fadeOut = yes) ->
			dfd = new $.Deferred()

			content = @$el.find ".todo-content"
			if className then @$el.addClass className

			timeline = new TimelineLite { onComplete: dfd.resolve }
			timeline.to( content, 0.3, { left: @$el.outerWidth(), ease: Power2.easeInOut } )
			if fadeOut then timeline.to( @$el, 0.2, { alpha: 0, height: 0 }, "-=0.1" )

			return dfd.promise()
		swipeLeft: (className, fadeOut = yes) ->
			dfd = new $.Deferred()

			content = @$el.find ".todo-content"
			if className then @$el.addClass className

			timeline = new TimelineLite { onComplete: dfd.resolve }
			timeline.to( content, 0.3, { left: 0 - @$el.outerWidth(), ease: Power2.easeInOut } )
			if fadeOut then timeline.to( @$el, 0.2, { alpha: 0, height: 0 }, "-=0.1" )

			return dfd.promise()
		reset: ->
			content = @$el.find ".todo-content"
			@$el.removeClass "scheduled completed todo"
			content.css( "left", "" )
			@$el.css( "opacity", "" )
		cleanUp: ->
			$(window).off( "resize", @setBounds )
			@$el.off()
			@undelegateEvents()
			@stopListening()
			@customCleanUp()