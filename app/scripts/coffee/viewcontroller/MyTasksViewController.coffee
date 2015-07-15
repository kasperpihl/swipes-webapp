define [
	"underscore"
	"gsap"
	"text!templates/viewcontroller/my-tasks-view-controller.html"
	], (_, TweenLite, Template) ->
	Backbone.View.extend
		initialize: ->
			@setTemplate()
			@render()
		setTemplate: ->
			@template = _.template Template
		render: ->
			$("#main").html(@template({}))
		
		
		open: (options) ->
			section = options.id
			@loadView(section).then (View) =>
				className = "todo"
				className = "scheduled" if section is "later"
				className = "completed" if section is "done"
				newView = new View( el: "ol.todo-list.#{ className }" )

				if @currView? then @transitionOut( @currView ).then =>
					@transitionIn( newView ).then ->
						newView.transitionInComplete.call newView, options

				else @transitionIn( newView ).then ->
					newView.transitionInComplete.call newView, options
		loadView: (section) ->
			dfd = new $.Deferred()
			if section is "later" then require ["js/view/Scheduled"], (View) -> dfd.resolve View
			else if section is "done" then require ["js/view/Completed"], (View) -> dfd.resolve View
			else require ["js/view/Todo"], (View) -> dfd.resolve View

			return dfd.promise()

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
		destroy: ->
			@currView?.remove()