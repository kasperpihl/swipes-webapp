define [
	"jquery"
	"backbone"
	"js/model/ClockWork"
	"js/controller/ViewController"
	"js/controller/AnalyticsController"
	"js/router/MainRouter"
	"js/collection/ToDoCollection"
	"js/collection/TagCollection"
	"js/view/nav/ListNavigation"
	"js/controller/TaskInputController"
	"js/controller/SidebarController"
	"js/controller/ScheduleController"
	"js/controller/FilterController"
	"js/controller/SettingsController"
	"js/controller/ErrorController"
	"js/controller/SyncController"
	"gsap"
	"localytics-sdk"
	], ($, Backbone, ClockWork, ViewController, AnalyticsController, MainRouter, ToDoCollection, TagCollection, ListNavigation, TaskInputController, SidebarController, ScheduleController, FilterController, SettingsController, ErrorController, SyncController) ->
	class Swipes
		UPDATE_INTERVAL: 30
		UPDATE_COUNT: 0
		constructor: ->
			#@hackParseAPI()
			Backbone.once( "sync-complete", @init, @ )

			@analytics = new AnalyticsController()
			@errors = new ErrorController()
			@todos = new ToDoCollection()
			@tags = new TagCollection()

			@sync = new SyncController()
			
			@updateTimer = new ClockWork()

			
			##@tags.fetch()

			
			$(window).focus @fetchTodos
				
		isBusy: ->
			# Are any todos being saved right now?
			if @todos.length?
				for task in @todos.models when task._saving
					return yes

			# Are any tags being saved right now?
			if @tags.length?
				for tag in @tags.models when tag._saving
					return yes

			# Are any tasks being edited right now
			if location.href.indexOf( "edit/" ) isnt -1
				return yes

			# Are any tasks selected right now?
			if @todos.length
				if @todos.where( selected:yes ).length
					return yes

			return no
		###hackParseAPI: ->
			# Add missing mehods to Parse.Collection.prototype
			for method in ["where", "findWhere"]
				if not Parse.Collection::[method]?
					Parse.Collection::[method] = Backbone.Collection::[method]
		###
		init: ->
			@cleanUp()

			@viewController = new ViewController()
			@nav = new ListNavigation()
			@router = new MainRouter()
			@scheduler = new ScheduleController()
			@input = new TaskInputController()
			@sidebar = new SidebarController()
			@filter = new FilterController()
			@settings = new SettingsController()

			Backbone.history.start( pushState: no )

			$("body").removeClass "loading"
			# $("")

			#@startAutoUpdate()

		###update: ->
			if not @isBusy()
				@fetchTodos()
				@UPDATE_COUNT++

			@lastUpdate = new Date()
			TweenLite.delayedCall( @UPDATE_INTERVAL, @update, null, @ );
		startAutoUpdate: ->
			TweenLite.delayedCall( @UPDATE_INTERVAL, @update, null, @ );
		stopAutoUpdate: ->
			TweenLite.killDelayedCallsTo @update###
		cleanUp: ->
			#@stopAutoUpdate()
			##@tags?.destroy()
			@viewController?.destroy()
			@nav?.destroy()
			@router?.destroy()
			@scheduler?.destroy()
			@input?.destroy()
			@sidebar?.destroy()
			@filter?.destroy()
			@settings?.destroy()

			# If we init multiple times, we need to make sure to stop the history between each.
			if Parse.History.started then Parse.history.stop()
		fetchTodos: ->
			swipy.sync.sync()