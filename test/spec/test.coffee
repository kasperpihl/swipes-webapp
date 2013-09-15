
require [
	"jquery", 
	"underscore", 
	"backbone"
	], ($, _, Backbone) ->
	
	contentHolder = $("#content-holder")
	
	helpers = 
		getListItemModels: ->
			[
					title: "Follow up on Martin"
					order: 0
					schedule: new Date()
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["work", "client"]
					notes: ""
				,
					title: "Dummy task #3"
					order: 2
					schedule: new Date()
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["work", "client"]
					notes: ""
				,
					title: "Dummy task #2"
					order: 1
					schedule: new Date("October 13, 2013 11:13:00")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["work", "client"]
					notes: ""
				,
					title: "Dummy task #4"
					order: 3
					schedule: new Date("September 18, 2013 16:30:02")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					notes: ""
			]
		renderTodoList: ->
			dfd = new $.Deferred()
			require ["text!templates/todo-list.html", "model/ToDoModel", "view/list/DesktopListItem"], (ListTempl, Model, View) ->
				tmpl = _.template ListTempl

				data = { title: "Tomorrow" }

				contentHolder.html $("<ol class='todo'></ol>").append( tmpl data )



				dfd.resolve()

			return dfd.promise()

	#
	# The Basics
	#
	describe "Basics", ->
		it "App should be up and running", ->
			expect( window.app ).to.exist

	#
	# To Do Model
	#
	require ["model/ToDoModel"], (Model) ->
		describe "List Item model", ->
			model = new Model()

			it "Should create scheduleStr property when instantiated", ->
				expect( model.get("scheduleString") ).to.equal "past"
			
			it "Should update scheduleStr when schedule property is changed", ->
				date = model.get "schedule"

				# unset for change event to occur
				model.unset "schedule"
				
				date.setDate date.getDate()+1
				model.set( "schedule", date )

				expect( model.get("scheduleString") ).to.equal "Tomorrow"

			it "Should create timeStr property when model is instantiated", ->
				expect( model.get("timeStr") ).to.exist

			it "Should update timeStr when schedule property is changed", ->
				timeBeforeChange = model.get "timeStr"
				
				date = model.get "schedule"
				# Unset because its an object and wont trigger a change if we just update the object itself.
				model.unset "schedule"

				date.setHours date.getHours() - 1
				model.set( "schedule", date )
				
				timeAfterChange = model.get "timeStr"
				
				expect( timeBeforeChange ).to.not.equal timeAfterChange

	#
	# To Do View
	#
	require ["collection/ToDoCollection", "model/ToDoModel", "view/list/DesktopListItem"], (ToDoCollection, Model, View) ->
		helpers.renderTodoList().then ->
			list = contentHolder.find(".todo ol")

			do ->
				model = new Model helpers.getListItemModels()[0]
				view = new View { model }
				
				describe "To Do View: Selecting", ->

					list.append view.el
					view.$el.click()
				
					it "Should toggle selected property on model when clicked", ->
						expect( model.get "selected" ).to.be.true
					
					it "Should toggle selected class on element when clicked", ->
						expect( view.$el.hasClass "selected" ).to.be.true
				
				list.empty()

			do ->
				todos = new ToDoCollection helpers.getListItemModels()
				views = ( new View( model: model ) for model in todos.models )
				list.append view.el for view in views
				
				describe "To Do View: Hovering", ->

					it "All views should listen for 'allow-toggle-completed' and 'allow-toggle-schedule' event and toggle if they are 'selected'", ->
						# Lyt på event emits fra Backbone obj.
						expect(2).to.be.lessThan 1
					it "All views should listen for 'allow-toggle-completed' and 'allow-toggle-schedule' event and toggle if they are the current hovered view, no matter if they are selected or not", ->
						# Maybe compare e.currentTarget to self like if (selected is true or e.currentTarget is @)
						expect(2).to.be.lessThan 1