###

###
define [
	"underscore"
	"text!templates/tasklist/edit-task.html"
	"js/view/tasklist/tabs/ActionTab"
	], (_, EditTaskTmpl, ActionTab) ->
	Backbone.View.extend
		className: "edit-task"
		events:
			"click .nav-item": "clickedNav"
			"click .go-back": "back"
		back: ->
			if @delegate? and _.isFunction(@delegate.editTaskDidClickBack)
				@delegate.editTaskDidClickBack(@)
			#swipy.router.back({trigger:false})
			false
		initialize: ->
			throw new Error("Model must be added when constructing EditTask") if !@model?
			@template = _.template EditTaskTmpl, {variable: "data" }
			@bouncedRender = _.debounce(@render, 5)
		render: ->
			@$el.html @template( task: @model )
			setTimeout( =>
				@loadActionSteps()
			,0)
			return @
		loadActionSteps: ->
			@actionTab = new ActionTab({model: @model})
			@$el.find(".action-step-container").html @actionTab.el
			@actionTab.loadActionSteps() 
		remove: ->
			@actionTab?.remove()
			@$el.empty()