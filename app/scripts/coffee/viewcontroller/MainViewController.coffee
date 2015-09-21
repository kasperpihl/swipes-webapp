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
				@currentViewController.open( viewcontroller, options )
			else
				@loadViewController(viewcontroller).then (ViewController) =>
					@currentViewController?.destroy()
					viewController = new ViewController()
					viewController.open( viewcontroller, options )
					@currentControllerName = viewcontroller
					@currentViewController = viewController
			swipy.activeId = options.id if options?.id
			swipy.sync?.shortBouncedSync()
			activeMenuDet = viewcontroller
			if viewcontroller is "im"
				activeMenuDet = "member"
			activeMenu = "sidebar-"+activeMenuDet + "-" + options.id if options?.id
			Backbone.trigger("set-active-menu", activeMenu)
		loadViewController: (viewcontroller) ->
			dfd = new $.Deferred()
			if viewcontroller is "im" then require ["js/viewcontroller/ChannelViewController"], (VC) -> dfd.resolve VC
			else if viewcontroller is "channel" then require ["js/viewcontroller/ChannelViewController"], (VC) -> dfd.resolve VC
			else if viewcontroller is "group" then require ["js/viewcontroller/ChannelViewController"], (VC) -> dfd.resolve VC
			else if viewcontroller is "search" then require ["js/viewcontroller/SearchViewController"], (VC) -> dfd.resolve VC
			else require ["js/viewcontroller/MyTasksViewController"], (VC) -> dfd.resolve VC
			return dfd.promise()
		destroy: ->
			@currView?.remove()
			Backbone.off( null, null, @ )