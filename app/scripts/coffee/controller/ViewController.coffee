define [
	"backbone"
	"gsap"
	# Cache views
	"view/Todo"
	"view/Completed"
	"view/Scheduled"
	], (Backbone, TweenLite) ->
	class ViewController
		constructor: (opts) ->
			@init()

		init: ->
			# Listen for navigation events
			Backbone.on( 'navigate/view', (slug) => @goto slug )
			Backbone.on( 'edit/task', (taskId) => @editTask taskId )
		
		goto: (slug) ->
			$("body").removeClass "edit-mode"
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
						@transitionIn( editView ).then ->
							editView.transitionInComplete?.call editView
			else
				require ["view/editor/EditTask"], (EditTaskView) =>
					editView = new EditTaskView( model: model )
					$("#main-content").prepend editView.el
					@transitionIn( editView ).then ->
						editView.transitionInComplete?.call editView
		
		transitionViews: (slug) ->
			# Make first letter uppercase
			viewName = slug[0].toUpperCase() + slug[1...]

			require ["view/#{ viewName }"], (View) =>
				newView = new View( el: "ol.todo-list.#{ slug }" )

				if @currView?
					@transitionOut( @currView ).then =>
						@transitionIn( newView ).then ->
							newView.transitionInComplete?.call newView
				else
					@transitionIn( newView ).then ->
						newView.transitionInComplete?.call newView

		transitionOut: (view) ->
			dfd = new $.Deferred()

			opts = 
				alpha: 0
				onComplete: =>
					view.$el.addClass "hidden"
					view.remove()
					dfd.resolve()

			TweenLite.to( view.$el, 0, opts )
			
			return dfd.promise()
		transitionIn: (view) ->
			dfd = new $.Deferred()
			
			opts = 
				alpha: 1
				onComplete: dfd.resolve

			view.$el.removeClass "hidden"
			TweenLite.fromTo( view.$el, 0, { alpha: 0 }, opts )
			
			@currView = view
			
			return dfd.promise()