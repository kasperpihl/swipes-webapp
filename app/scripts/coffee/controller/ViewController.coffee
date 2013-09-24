define ["backbone", "gsap"], (Backbone, TweenLite) ->
	class ViewController
		constructor: (opts) ->
			@init()
			@navLinks = $ ".list-nav a"
		init: ->
			# Listen for navigation events
			Backbone.on( 'navigate/view', (slug) => @goto slug )
			Backbone.on( 'edit/task', (taskId) => @editTask taskId )
		
		goto: (slug) ->
			$("body").removeClass "edit-mode"
			console.log "Go to #{slug}"
			@updateNavigation slug
			@transitionViews slug

		editTask: (taskId) ->
			$("body").addClass "edit-mode"

			model = m for m in swipy.todos.models when m.cid is taskId
			if not model? then return console.warn "Model with id #{taskId} couldn't be foudn"

			if @currView?
				@transitionOut( @currView ).then =>
					require ["view/editor/EditTask"], (EditTaskView) =>
						editView = new EditTaskView( model: model )
						$("#main-content").prepend editView.el
						@transitionIn editView
			else
				require ["view/editor/EditTask"], (EditTaskView) =>
					editView = new EditTaskView( model: model )
					$("#main-content").prepend editView.el
					@transitionIn editView
		
		updateNavigation: (slug) =>
			@navLinks.each ->
				link = $ @
				isCurrLink = if link.attr( "href" )[1...] is slug then yes else no
				link.toggleClass( "active", isCurrLink )
		
		transitionViews: (slug) ->
			# Make first letter uppercase
			viewName = slug[0].toUpperCase() + slug[1...]

			require ["view/#{ viewName }"], (View) =>
				newView = new View( el: "ol.todo-list.#{ slug }" )

				if @currView? 
					@transitionOut( @currView ).then =>
						@transitionIn newView
				else
					@transitionIn newView

		transitionOut: (view) ->
			dfd = new $.Deferred()

			opts = 
				alpha: 0
				onComplete: =>
					view.$el.addClass "hidden"
					view.cleanUp()
					dfd.resolve()

			TweenLite.to( view.$el, 0.15, opts )
			
			return dfd.promise()
		transitionIn: (view) ->
			dfd = new $.Deferred()
			
			opts = 
				alpha: 1
				onComplete: dfd.resolve

			view.$el.removeClass "hidden"
			TweenLite.fromTo( view.$el, 0.4, { alpha: 0 }, opts )
			
			@currView = view
			
			return dfd.promise()