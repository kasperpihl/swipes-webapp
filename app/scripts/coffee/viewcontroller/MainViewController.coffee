define [
	"underscore"
	"gsap"
	], (_, TweenLite) ->
	class MainViewController
		constructor: (opts) ->
			@init()
		init: ->
			# Listen for navigation events
			Backbone.on( 'open/viewcontroller', @openVC, @)
		openVC: (viewcontroller, options) ->
			if @currentControllerName is viewcontroller
				@currentViewController.open( options )
			else

				@loadViewController(viewcontroller).then (ViewController) =>
					@currentViewController?.destroy()
					viewController = new ViewController()
					viewController.open( options )
					@currentControllerName = viewcontroller
					@currentViewController = viewController
			Backbone.trigger("set-active-menu", "sidebar-"+viewcontroller + "-" + options.id)
		loadViewController: (viewcontroller) ->
			dfd = new $.Deferred()
			if viewcontroller is "member" then require ["js/viewcontroller/TeamMemberViewController"], (VC) -> dfd.resolve VC
			else if viewcontroller is "project" then require ["js/viewcontroller/ProjectViewController"], (VC) -> dfd.resolve VC
			else require ["js/viewcontroller/MyTasksViewController"], (VC) -> dfd.resolve VC
			return dfd.promise()
		destroy: ->
			@currView?.remove()
			Backbone.off( null, null, @ )