###

###
define [
	"underscore"
	"text!templates/tasklist/task.html"
	"js/view/modal/ScheduleModal"
	], (_, TaskTmpl, ScheduleModal) ->
	Backbone.View.extend
		tagName: "li"
		className: "task-item"
		events:
			"click .actions a": "handleAction"
		initialize: ->
			throw new Error("Model must be added when constructing a TaskCard") if !@model?
			@template = _.template TaskTmpl, {variable: "data" }
			@bouncedRender = _.debounce(@render, 5)
			_.bindAll( @, 'clickedTask', 'handleAction', 'bouncedRender' )
			@listenTo( @model, "change:selected", @onSelected )
			@listenTo( @model, "change:assignees", @bouncedRender )
		clickedTask: (e) ->
			if @taskDelegate? and _.isFunction(@taskDelegate.taskDidClick)
				@taskDelegate.taskDidClick(@, e)
		handleAction: (e) ->
			# Actual trigger logic
			return false if !@taskDelegate?
			
			self = @
			if $(e.currentTarget).hasClass("complete-button") and _.isFunction(@taskDelegate.taskCardDidComplete)
				@animateWithClass("fadeOutRight").then(->
					self.taskDelegate.taskCardDidComplete(self)
				)
			if $(e.currentTarget).hasClass("schedule-button")
				Backbone.trigger( "show-scheduler", [@], e )
			if $(e.currentTarget).hasClass("now-button")
				Backbone.trigger( "move-to-now", [@], e )
			
			if $(e.currentTarget).hasClass("assign-button")
				Backbone.trigger( "show-assign", @model, e)
			false
		scheduleTask: ->
		animateWithClass: (animateClass) ->
			dfd = new $.Deferred()
			@$el.addClass("animated")
			@$el.addClass(animateClass)
			self = @
			setTimeout(->
				self.$el.removeClass("animated")
				self.$el.removeClass(animateClass)
				dfd.resolve()
			, 300)
			return dfd.promise()
		render: ->
			if @model.get("selected")
				@$el.addClass('selected')
			if @model.get "animateIn"
				@$el.addClass "animate-in"
				@model.set "animateIn", null, {localSync: true}
			@$el.attr('id', "task-"+@model.id )
			@$el.html @template( task: @model, showSource: @showSource, showSchedule: @showSchedule )

			return @
		onSelected: (model, selected) ->
			@$el.toggleClass( "selected", selected )
		remove: ->
			@$el.empty()