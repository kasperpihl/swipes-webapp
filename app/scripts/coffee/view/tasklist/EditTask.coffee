###

###
define [
	"underscore"
	"text!templates/tasklist/edit-task.html"
	"js/view/tasklist/TaskList"
	"js/handler/TaskHandler"
	], (_, EditTaskTmpl, TaskList, TaskHandler) ->
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
			@taskHandler?.destroy()
			@taskList?.remove()
			@setSectionTitle("ACTIONS")

			@taskList = new TaskList()
			@taskList.setActionList()
			@taskList.targetSelector = "#task-"+@model.id + " .edit-task .tab-container"
			@taskList.enableDragAndDrop = true

			@taskHandler = new TaskHandler()
			@taskHandler.listSortAttribute = "projectOrder"
			@taskList.taskDelegate = @taskHandler
			@taskList.dragDelegate = @taskHandler
			@taskList.dataSource = @taskHandler
			self = @
			@taskCollectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					return task.get("parentLocalId") is self.model.id
			})
			console.log @taskCollectionSubset.child.toJSON()
			@taskHandler.loadCollection(@taskCollectionSubset.child)
			@taskList.render()

		remove: ->
			@$el.empty()