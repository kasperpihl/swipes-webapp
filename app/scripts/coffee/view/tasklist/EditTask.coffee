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
		initialize: ->
			throw new Error("Model must be added when constructing EditTask") if !@model?
			@template = _.template EditTaskTmpl, {variable: "data" }
			@bouncedRender = _.debounce(@render, 5)
		render: ->
			@$el.html @template( task: @model )
			return @
		setSectionTitle: (title) ->
			@$el.find(".section-title > span").html(title)
			@realignProgressBar()
		realignProgressBar: ->
			# Trying to make an estimate of the length of the text
			# This is technically not possible prerender and therefore this is a guess
			widthOfText = @$el.find('.section-title > span').text().length * 8

			actualWidth = widthOfText + 50
			@$el.find('.section-title').css("width",actualWidth+"px")
			@$el.find('.progress').parent().css("paddingRight",actualWidth+"px")
			@$el.find('.shapeline').css("right",actualWidth+"px")
		clickedNav: (e) ->
			
			target = $(e.currentTarget)
			return false if target.hasClass("active")
			@loadTarget(target)
			false
		loadTarget: (target) ->
			@$el.find('.nav-item.active').removeClass("active")
			target.addClass("active")
			if target.hasClass("actionTab")
				@loadActionSteps()
		loadActionSteps: ->
			@actionTab = new ActionTab({model: @model})
			$("#task-"+@model.id + " .edit-task .tab-container").html @actionTab.el
			@actionTab.loadActionSteps() 
			@setSectionTitle("ACTIONS")
		loadSchedule: ->
		loadAssignees: ->
		loadAttachments: ->

		remove: ->
			@$el.empty()