
require [
	"jquery", 
	"underscore", 
	"backbone"
	], ($, _, Backbone) ->
	
	contentHolder = $("#content-holder")
	
	helpers = 
		getDummyModels: ->
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
					title: "Completed Dummy task #3"
					order: 2
					schedule: new Date()
					completionDate: new Date("July 12, 2013 11:51:45")
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
			expect( swipy ).to.exist

	#
	# To Do Model
	#
	require ["model/ToDoModel"], (Model) ->
		describe "List Item model", ->
			model = new Model()

			it "Should create scheduleStr property when instantiated", ->
				expect( model.get("scheduleStr") ).to.equal "the past"
			
			it "Should update scheduleStr when schedule property is changed", ->
				date = model.get "schedule"

				# unset for change event to occur
				model.unset "schedule"
				
				date.setDate date.getDate()+1
				model.set( "schedule", date )

				expect( model.get("scheduleStr") ).to.equal "Tomorrow"

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

			it "Should update completedStr when completionDate is changed", ->
				model.set( "completionDate", new Date() )
				expect( model.get "completionStr" ).to.exist
				expect( model.get "completionTimeStr" ).to.exist

			# it "ScheduleStr should be a real date (Not Thursday) for instance, when schedule date is more than a week from now", ->
				# expect(2).to.be.lessThan 1

			# it "completedStr should be a real date (Not Thursday) for instance, when completion date is more than a week ago", ->
				# expect(2).to.be.lessThan 1

	#
	# To Do Collection
	#
	require ["collection/ToDoCollection", "model/ToDoModel"], (ToDoCollection, ToDo) ->
		describe "To Do collection", ->
			todos = null

			beforeEach ->
				now = new Date()
				future = new Date()
				past = new Date()

				future.setDate now.getDate() + 1
				past.setDate now.getDate() - 1

				scheduledTask = new ToDo { title: "scheduled task", schedule: future }
				todoTask = new ToDo { title: "todo task", schedule: now }
				completedTask = new ToDo { title: "completed task", completionDate: past }
				
				todos = new ToDoCollection [scheduledTask, todoTask, completedTask]

			it "getActive() should return all tasks to do right now", ->
				expect(todos.getActive().length).to.equal 1
			
			it "getScheduled() Should return all scheduled tasks", ->
				expect(todos.getScheduled().length).to.equal 1
			
			it "getCompleted() Should return all completed tasks", ->
				expect(todos.getCompleted().length).to.equal 1

	#
	# To Do View
	#
	require ["collection/ToDoCollection", "model/ToDoModel", "view/list/DesktopListItem"], (ToDoCollection, Model, View) ->
		helpers.renderTodoList().then ->
			list = contentHolder.find(".todo ol")

			do ->
				model = new Model helpers.getDummyModels()[0]
				view = new View { model }
				
				describe "To Do View: Selecting", ->


					list.append view.el
					view.$el.click()
				
					it "Should toggle selected property on model when clicked", ->
						expect( model.get "selected" ).to.be.true
					
					it "Should toggle selected class on element when clicked", ->
						expect( view.$el.hasClass "selected" ).to.be.true
				

			do ->
				todos = views = null

				describe "To Do View: Hovering", ->
					beforeEach ->
						# Clear out list to remove any 'unsanitary' data
						list.empty()
						todos = new ToDoCollection helpers.getDummyModels()
						views = ( new View( model: model ) for model in todos.models )
						list.append view.el for view in views

					after ->
						contentHolder.empty()


					it "Should be unresponsive to 'hover-complete' event when not selected", ->
						Backbone.trigger "hover-complete"
						count = 0
						count++ for view in views when view.$el.hasClass "hover-complete"

						expect( count ).to.equal 0

					it "Should be unresponsive to 'hover-schedule' event when not selected", ->
						Backbone.trigger "hover-schedule"
						count = 0
						count++ for view in views when view.$el.hasClass "hover-schedule"

						expect( count ).to.equal 0
					

					it "Should get the 'hover-complete' CSS class when 'hover-complete' event is triggered when selected", ->
						# Make 2 views selected
						views[0].model.set( "selected", true )
						views[1].model.set( "selected", true )

						Backbone.trigger "hover-complete"
						
						count = 0
						count++ for view in views when view.$el.hasClass "hover-complete"

						expect( count ).to.equal 2

					it "Should remove the 'hover-complete' CSS class when 'unhover-complete' event is triggered when selected", ->
						# Make 2 views selected
						views[0].model.set( "selected", true )
						views[1].model.set( "selected", true )

						views[0].$el.addClass "hover-complete"
						views[1].$el.addClass "hover-complete"

						Backbone.trigger "unhover-complete"
						count = 0
						count++ for view in views when view.$el.hasClass "hover-complete"

						expect( count ).to.equal 0

					it "Should get the 'hover-schedule' CSS class when 'hover-schedule' event is triggered when selected", ->
						# Make 2 views selected
						views[0].model.set( "selected", true )
						views[1].model.set( "selected", true )

						Backbone.trigger "hover-schedule"
						
						count = 0
						count++ for view in views when view.$el.hasClass "hover-schedule"

						expect( count ).to.equal 2

					it "Should remove the 'hover-schedule' CSS class when 'unhover-schedule' event is triggered when selected", ->
						# Make 2 views selected
						views[0].model.set( "selected", true )
						views[1].model.set( "selected", true )

						views[0].$el.addClass "hover-schedule"
						views[1].$el.addClass "hover-schedule"

						Backbone.trigger "unhover-schedule"
						count = 0
						count++ for view in views when view.$el.hasClass "hover-schedule"

						expect( count ).to.equal 0

	#
	# Scheduled list View
	#
	require ["view/Schedule", "model/ToDoModel"], (ScheduleView, ToDo) ->
		laterToday = new Date()
		tomorrow = new Date()
		nextMonth = new Date()
		now = new Date()

		laterToday.setHours now.getHours() + 1
		tomorrow.setDate now.getDate() + 1
		nextMonth.setMonth now.getMonth() + 1

		todos = [
			new ToDo( { title: "In a month", schedule: nextMonth } )
			new ToDo( { title: "Tomorrow", schedule: tomorrow } ), 
			new ToDo( { title: "In 1 hour", schedule: laterToday } ), 
		]

		view = new ScheduleView()

		describe "Schedule list view", ->
			it "Should order tasks by chronological order", ->
				result = view.groupTasks todos
				expect(result[0].deadline).to.equal "Later today"
				expect(result[1].deadline).to.equal "Tomorrow"

				# If 1 and 2 is correct we know that 3 is too.

	#
	# To do list View
	#
	require ["view/Todo", "model/ToDoModel"], (ToDoView, ToDo) ->
		todos = [ new ToDo( title: "three" ), new ToDo( title: "two", order: 2 ), new ToDo( title: "one", order: 1 ) ]
		view = new ToDoView()

		describe "To Do list view", ->
			it "Should order tasks by models 'order' property", ->
				result = view.groupTasks todos
				expect(result[0].tasks[0].get "title").to.equal "one"
				expect(result[0].tasks[1].get "title").to.equal "two"
				expect(result[0].tasks[2].get "title").to.equal "three"
	
	#
	# Completed list View
	#
	require ["view/Completed", "model/ToDoModel"], (CompletedView, ToDo) ->
		earlierToday = new Date()
		yesterday = new Date()
		prevMonth = new Date()
		now = new Date()

		earlierToday.setHours now.getHours() - 1
		yesterday.setDate now.getDate() - 1
		prevMonth.setMonth now.getMonth() - 1

		todos = [
			new ToDo( { title: "Last month", completionDate: prevMonth } )
			new ToDo( { title: "Yesterday", completionDate: yesterday } ), 
			new ToDo( { title: "An hour ago", completionDate: earlierToday } ), 
		]

		view = new CompletedView()

		describe "Completed list view", ->
			it "Should order tasks by chronological order", ->
				result = view.groupTasks todos
				expect(result[0].deadline).to.equal "Earlier today"
				expect(result[1].deadline).to.equal "Yesterday"

				# If 1 and 2 is correct we know that 3 is too.