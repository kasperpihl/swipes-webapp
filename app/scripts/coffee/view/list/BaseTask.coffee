define ["underscore", "backbone", "gsap", "timelinelite", "text!templates/task.html"], (_, Backbone, TweenLite, TimelineLite, TaskTmpl) ->
	Backbone.View.extend
		tagName: "li"
		initialize: ->
			_.bindAll( @, "onSelected", "setBounds", "toggleSelected", "edit", "handleAction" )
			
			@listenTo( @model, "change:selected", @onSelected )
			$(window).on "resize", @setBounds

			@setTemplate()	
			@init()
			@render()

			# Bind all events manually, so events extending me can use the
			# events hash freely
			@$el.on( "click", ".todo-content", @toggleSelected )
			@$el.on( "dblclick", "h2", @edit )
			@$el.on( "click", ".action", @handleAction )
		
		setTemplate: ->
			@template = _.template TaskTmpl

		setBounds: ->
			@bounds = @el.getClientRects()[0]
		
		init: ->
			# Hook for views extending me
		
		toggleSelected: ->
			currentlySelected = @model.get( "selected" ) or false
			@model.set( "selected", !currentlySelected )

		handleAction: (e) ->
			# Set trigger. One or more elements, but always wrapped in an array ready to loop over.
			trigger = [@model]
			selectedTasks = swipy.todos.where( selected: yes )
			if selectedTasks.length 
				selectedTasks = _.reject( selectedTasks, (m) => m.cid is @model.cid )
				trigger.push task for task in selectedTasks

			# Actual trigger logic
			if $( e.currentTarget ).hasClass "schedule"
				
				Backbone.trigger( "schedule-task", trigger )
			else if $( e.currentTarget ).hasClass "complete"
				Backbone.trigger( "complete-task", trigger )
			else if $( e.currentTarget ).hasClass "todo"
				Backbone.trigger( "todo-task", trigger )

		onSelected: (model, selected) ->
			@$el.toggleClass( "selected", selected )
		
		edit: ->
			swipy.router.navigate( "edit/#{ @model.cid }", yes )
		
		render: ->
			# If template isnt set yet, just return the empty element
			return @el if !@template?
			
			@$el.html @template @model.toJSON()

			return @el
		
		remove: ->
			@cleanUp()
			@$el.remove()
		
		customCleanUp: ->
			# Hook for views extending me
		
		swipeLeft: (className) ->
			dfd = new $.Deferred()
			
			content = @$el.find ".todo-content"
			if className then @$el.addClass className

			timeline = new TimelineLite { onComplete: dfd.resolve }
			timeline.to( content, 0.4, { left: @$el.outerWidth() } )
			timeline.to( @$el, 0.4, { alpha: 0 }, "-=0.2" )
			
			return dfd.promise()
		swipeRight: (className) ->
			dfd = new $.Deferred()
			
			content = @$el.find ".todo-content"
			if className then @$el.addClass className

			timeline = new TimelineLite { onComplete: dfd.resolve }
			timeline.to( content, 0.4, { left: 0 - @$el.outerWidth() } )
			timeline.to( @$el, 0.4, { alpha: 0 }, "-=0.2" )
			
			return dfd.promise()

		reset: ->
			content = @$el.find ".todo-content"
			@$el.removeClass "scheduled completed todo"
			content.css( "left", "" )
			@$el.css( "opacity", "" )

		cleanUp: ->
			$(window).off()
			@$el.off()
			@undelegateEvents()
			@stopListening()
			@customCleanUp()