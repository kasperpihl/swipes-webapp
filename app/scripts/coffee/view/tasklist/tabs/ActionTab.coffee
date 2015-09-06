###

###
define [
	"underscore"
	"text!templates/tasklist/tabs/action-tab.html"
	"js/view/tasklist/TaskList"
	"js/handler/TaskHandler"
	"js/view/tasklist/tabs/AddActionRow"
	], (_, ActionTabTmpl, TaskList, TaskHandler, AddActionRow) ->
	Backbone.View.extend
		className: "action-tab"
		initialize: ->
			throw new Error("Model must be added when constructing EditTask") if !@model?
			@template = _.template ActionTabTmpl, {variable: "data" }
			@bouncedRender = _.debounce(@render, 5)
			@addActionRow = new AddActionRow()
			@addActionRow.addDelegate = @
			@render()
		render: ->
			@$el.html @template( task: @model )
			@addActionRow.render()
			@$el.find(".add-action-outer-container").html(@addActionRow.el)
			return @
		loadActionSteps: ->
			@taskHandler?.destroy()
			@taskList?.remove()


			@taskList = new TaskList()
			@taskList.setActionList()
			@taskList.targetSelector = "#task-"+@model.id + " .edit-task .action-list-container"
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

			@taskHandler.loadCollection(@taskCollectionSubset.child)
			@taskList.render()
		actionRowDidCreateAction: (actionRow, title, options) ->
			@taskCollectionSubset.child.createAction(@model, title, options)
		remove: ->
			@taskHandler?.destroy()
			@taskList?.remove()
			@$el.empty()