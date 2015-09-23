define [
	"underscore"
	"text!templates/tasklist/toggle-completed-tasks.html"
	], (_, ToggleTemplate) ->
	Backbone.View.extend
		initialize: (options) ->
			self = @
			@options = options

			@setTemplates()
			@listenTo( Backbone, "update/numberOfTasks", @toggleVisibility)
		setTemplates: ->
			@template = _.template ToggleTemplate
		toggleVisibility: (number) ->
			@targetSelector = $(@options.targetSelector)
			@targetSelector.toggle(number > 0)
		taskListRefresh: (e) ->
			@.targetSelector.find('.toggle-text-one').toggleClass 'active'
			@.targetSelector.find('.toggle-text-two').toggleClass 'active'
			Backbone.trigger("reload/taskhandler", {checked: e.target.checked})
		render: ->
			@targetSelector = $(@options.targetSelector)
			@targetSelector.html @template()

			#T_TODO use backbone events when figure out why they don't work here
			@targetSelector.find('.onoffswitch-checkbox').on 'click', @taskListRefresh.bind(@)

			return @
		destroy: ->
			@targetSelector.find('.onoffswitch-checkbox').off()