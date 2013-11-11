define ["jquery", "underscore", "backbone", "model/ToDoModel", "momentjs"], ($, _, Backbone, ToDoModel, moment) ->

	contentHolder = $("#content-holder")

	helpers =
		getDummyModels: ->
			future = new Date()
			future.setDate( future.getDate() + 1 )

			return [
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
					schedule: future
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
			require ["text!templates/task.html", "view/list/DesktopTask"], (TaskTmpl, View) ->
				tmpl = _.template TaskTmpl

				model = new ToDoModel { title: "Tomorrow" }

				contentHolder.html $("<ol class='todo'></ol>").append( tmpl model.toJSON() )

				dfd.resolve()

			return dfd.promise()

	###

	#
	# The Basics
	#
	describe "Basics", ->
		it "App should be up and running", ->
			# Overwrite todos with dummy data
			swipy.todos.reset helpers.getDummyModels()

			expect( swipy ).to.exist

		it "Should have scheduled tasks for testing", ->
			expect( swipy.todos.getScheduled() ).to.have.length.above 0

		it "Should have active tasks for testing", ->
			expect( swipy.todos.getActive() ).to.have.length.above 0

		it "Should have completed tasks for testing", ->
			expect( swipy.todos.getCompleted() ).to.have.length.above 0

	#
	# To Do Model
	#
	describe "Task model", ->
		model = new ToDoModel()

		describe "scheduleStr property", ->
			it "Should create scheduleStr property when instantiated, and the default should be: 'Today'", ->
				expect( model.get("scheduleStr") ).to.equal "Today"

			it "Should update scheduleStr when schedule property is changed", ->
				date = model.get "schedule"

				# unset for change event to occur
				model.unset "schedule"

				date.setDate date.getDate()+1
				model.set( "schedule", date )

				expect( model.get("scheduleStr") ).to.equal "Tomorrow"

			describe "differentiate scheduleStr for 'Today' base current time vs. task time", ->
				it "Should set scheduleStr to be 'Today' if the task is due today, prior to or equal to the current time", ->
					earlierToday = new Date()
					earlierToday.setMinutes earlierToday.getMinutes() - 1
					taskForEarlierToday = new ToDoModel( schedule: earlierToday )

					expect( taskForEarlierToday.get("scheduleStr") ).to.equal "Today"

				it "Should set scheduleStr to be 'Later today' if the task is due today, later than the current time", ->
					laterToday = new Date()
					laterToday.setMinutes laterToday.getMinutes() + 1
					taskForLaterToday = new ToDoModel( schedule: laterToday )

					expect( taskForLaterToday.get("scheduleStr") ).to.equal "Later today"

		describe "timeStr property", ->
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

		describe "completedStr property", ->
			it "Should update completedStr when completionDate is changed", ->
				model.set( "completionDate", new Date() )
				expect( model.get "completionStr" ).to.exist
				expect( model.get "completionTimeStr" ).to.exist

		describe "tags", ->
			it "Should make sure the models tags all exist in the global tags collection — And add them if they don't", ->
				dummyTagName = "wtf123-" + new Date().getTime()

				expect( swipy.tags.pluck "title" ).to.not.contain dummyTagName
				Backbone.trigger( "create-task", "Test that we add tags properly #" + dummyTagName )
				expect( swipy.tags.pluck "title" ).to.contain dummyTagName

	#
	# To Do Collection
	#
	require ["collection/ToDoCollection"], (ToDoCollection) ->
		describe "To Do collection", ->
			todos = null

			beforeEach ->
				now = new Date()
				future = new Date()
				past = new Date()

				# Put now 1 second in the past
				now.setSeconds now.getSeconds() - 1
				future.setDate now.getDate() + 1
				past.setDate now.getDate() - 1

				scheduledTask = new ToDoModel { title: "scheduled task", schedule: future }
				todoTask = new ToDoModel { title: "todo task", schedule: now }
				completedTask = new ToDoModel { title: "completed task", completionDate: past }

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
	require ["collection/ToDoCollection", "view/list/DesktopTask"], (ToDoCollection, View) ->
		helpers.renderTodoList().then ->
			list = contentHolder.find(".todo ol")

			do ->
				model = new ToDoModel helpers.getDummyModels()[0]
				view = new View { model }

				describe "To Do View: Selecting", ->

					list.append view.el
					view.$el.find( ".todo-content" ).click()

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


					it "Should get the 'hover-left' CSS class when 'hover-complete' event is triggered when selected", ->
						# Make 2 views selected
						views[0].model.set( "selected", true )
						views[1].model.set( "selected", true )

						Backbone.trigger "hover-complete"

						count = 0
						count++ for view in views when view.$el.hasClass "hover-left"

						expect( count ).to.equal 2

					it "Should remove the 'hover-left' CSS class when 'unhover-complete' event is triggered when selected", ->
						# Make 2 views selected
						views[0].model.set( "selected", true )
						views[1].model.set( "selected", true )

						views[0].$el.addClass "hover-complete"
						views[1].$el.addClass "hover-complete"

						Backbone.trigger "unhover-complete"
						count = 0
						count++ for view in views when view.$el.hasClass "hover-left"

						expect( count ).to.equal 0

					it "Should get the 'hover-right' CSS class when 'hover-schedule' event is triggered when selected", ->
						# Make 2 views selected
						views[0].model.set( "selected", true )
						views[1].model.set( "selected", true )

						Backbone.trigger "hover-schedule"

						count = 0
						count++ for view in views when view.$el.hasClass "hover-right"

						expect( count ).to.equal 2

					it "Should remove the 'hover-right' CSS class when 'unhover-schedule' event is triggered when selected", ->
						# Make 2 views selected
						views[0].model.set( "selected", true )
						views[1].model.set( "selected", true )

						views[0].$el.addClass "hover-right"
						views[1].$el.addClass "hover-right"

						Backbone.trigger "unhover-schedule"
						count = 0
						count++ for view in views when view.$el.hasClass "hover-right"

						expect( count ).to.equal 0

	#
	# Any list View
	#
	require ["view/List", "model/ToDoModel"], (ListView, ToDo) ->
		contentHolder.empty()
		list = new ListView();
		list.$el.appendTo contentHolder

		describe "Base list view", ->
			it "should add children when rendering", ->
				expect( list.$el.find "ol li" ).to.have.length.above 0

			it "Should remove all nested children as part of the cleanUp routine", ->
				list.cleanUp()
				expect( list.$el.find "ol li" ).to.have.length.lessThan 1

	#
	# Scheduled list View
	#
	require ["view/Scheduled"], (ScheduleView) ->
		laterToday = new Date()
		tomorrow = new Date()
		nextMonth = new Date()
		now = new Date()

		laterToday.setSeconds now.getSeconds() + 1
		tomorrow.setDate now.getDate() + 1
		nextMonth.setMonth now.getMonth() + 1

		todos = [
			new ToDoModel( { title: "In a month", schedule: nextMonth } )
			new ToDoModel( { title: "Tomorrow", schedule: tomorrow } ),
			new ToDoModel( { title: "In 1 hour", schedule: laterToday } ),
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
	require ["view/Todo"], (ToDoView) ->
		todos = [ new ToDoModel( title: "three" ), new ToDoModel( title: "two", order: 2 ), new ToDoModel( title: "one", order: 1 ) ]
		view = new ToDoView()

		describe "To Do list view", ->
			it "Should order tasks by models 'order' property", ->
				result = view.groupTasks todos
				expect(result[0].tasks[0].get "title").to.equal "one"
				expect(result[0].tasks[1].get "title").to.equal "two"
				expect(result[0].tasks[2].get "title").to.equal "three"

			it "Should make sure no two todos have the same order id", ->
				list = [
					new ToDoModel( { order: 0 } ),
					new ToDoModel( { order: 0 } ),
					new ToDoModel( { order: 2 } ),
					new ToDoModel( { order: 5 } )
				]

				newTasks = view.setTodoOrder list
				orders = _.invoke( newTasks, "get", "order" )

				expect(orders).to.have.length 4
				expect(orders).to.contain 0
				expect(orders).to.contain 1
				expect(orders).to.contain 2
				expect(orders).to.contain 3

			it "Should order todos by schdule date if no order is defined", ->
				first = new Date()
				second = new Date()
				third = new Date()

				second.setSeconds( second.getSeconds() + 1 )
				third.setSeconds( third.getSeconds() + 2 )

				list = [
					new ToDoModel( { title: "third", schedule: third } ),
					new ToDoModel( { title: "second", schedule: second } )
					new ToDoModel( { title: "first", schedule: first } )
				]

				result = view.setTodoOrder list
				firstModel = _.filter( result, (m) -> m.get( "title" ) is "first" )[0]
				secondModel = _.filter( result, (m) -> m.get( "title" ) is "second" )[0]
				thirdModel = _.filter( result, (m) -> m.get( "title" ) is "third" )[0]

				expect( result ).to.have.length 3
				expect( firstModel.get "order" ).to.equal 0
				expect( secondModel.get "order" ).to.equal 1
				expect( thirdModel.get "order" ).to.equal 2

			it "Should be able to mix in unordered and ordered items", ->
				first = new Date()
				second = new Date()

				second.setSeconds( second.getSeconds() + 1 )

				list = [
					new ToDoModel( { title: "third", schedule: second } ),
					new ToDoModel( { title: "first", schedule: first } ),
					new ToDoModel( { title: "second (has order)", order: 1 } ),
					new ToDoModel( { title: "fourth (has order)", order: 3 } )
				]

				result = view.setTodoOrder list
				firstModel = _.filter( result, (m) -> m.get( "title" ) is "first" )[0]
				secondModel = _.filter( result, (m) -> m.get( "title" ) is "second (has order)" )[0]
				thirdModel = _.filter( result, (m) -> m.get( "title" ) is "third" )[0]
				fourthModel = _.filter( result, (m) -> m.get( "title" ) is "fourth (has order)" )[0]

				expect( result ).to.have.length 4
				expect( firstModel.get "order" ).to.equal 0
				expect( secondModel.get "order" ).to.equal 1
				expect( thirdModel.get "order" ).to.equal 2
				expect( fourthModel.get "order" ).to.equal 3

			it "Should take models with order 3,4,5,6 and change them to 0,1,2,3", ->
				list = [
					new ToDoModel( { title: "first", order: 3 } ),
					new ToDoModel( { title: "second", order: 4 } ),
					new ToDoModel( { title: "third", order: 5 } ),
					new ToDoModel( { title: "fourth", order: 6 } )
				]

				result = view.setTodoOrder list
				first = _.filter( result, (m) -> m.get( "title" ) is "first" )[0]
				second = _.filter( result, (m) -> m.get( "title" ) is "second" )[0]
				third = _.filter( result, (m) -> m.get( "title" ) is "third" )[0]
				fourth = _.filter( result, (m) -> m.get( "title" ) is "fourth" )[0]

				expect( result ).to.have.length 4
				expect( first.get "order" ).to.equal 0
				expect( second.get "order" ).to.equal 1
				expect( third.get "order" ).to.equal 2
				expect( fourth.get "order" ).to.equal 3

			it "Should take models with order 0,1,11,5 and change them to 0,1,2,3", ->
				list = [
					new ToDoModel( { title: "first", order: 0 } ),
					new ToDoModel( { title: "second", order: 1 } ),
					new ToDoModel( { title: "third", order: 5 } ),
					new ToDoModel( { title: "fourth", order: 11 } )
				]

				result = view.setTodoOrder list
				first = _.filter( result, (m) -> m.get( "title" ) is "first" )[0]
				second = _.filter( result, (m) -> m.get( "title" ) is "second" )[0]
				third = _.filter( result, (m) -> m.get( "title" ) is "third" )[0]
				fourth = _.filter( result, (m) -> m.get( "title" ) is "fourth" )[0]

				expect( result ).to.have.length 4
				expect( first.get "order" ).to.equal 0
				expect( second.get "order" ).to.equal 1
				expect( third.get "order" ).to.equal 2
				expect( fourth.get "order" ).to.equal 3

			it "Should take models with order undefined,1,undefined,5 and change them to 0,1,2,3", ->
				list = [
					new ToDoModel( { title: "first" } ),
					new ToDoModel( { title: "second", order: 1 } ),
					new ToDoModel( { title: "third" } ),
					new ToDoModel( { title: "fourth", order: 5 } )
				]

				result = view.setTodoOrder list
				first = _.filter( result, (m) -> m.get( "title" ) is "first" )[0]
				second = _.filter( result, (m) -> m.get( "title" ) is "second" )[0]
				third = _.filter( result, (m) -> m.get( "title" ) is "third" )[0]
				fourth = _.filter( result, (m) -> m.get( "title" ) is "fourth" )[0]

				expect( result ).to.have.length 4
				expect( first.get "order" ).to.equal 0
				expect( second.get "order" ).to.equal 1
				expect( third.get "order" ).to.equal 2
				expect( fourth.get "order" ).to.equal 3

			it "Should take models with order 2,2,2,2 and change them to 0,1,2,3", ->
				list = [
					new ToDoModel( { title: "first", order: 2 } ),
					new ToDoModel( { title: "second", order: 2 } ),
					new ToDoModel( { title: "jtown", order: 2 } ),
					new ToDoModel( { title: "fourth", order: 2 } )
				]

				result = view.setTodoOrder list
				first = _.filter( result, (m) -> m.get( "title" ) is "first" )[0]
				second = _.filter( result, (m) -> m.get( "title" ) is "second" )[0]
				third = _.filter( result, (m) -> m.get( "title" ) is "jtown" )[0]
				fourth = _.filter( result, (m) -> m.get( "title" ) is "fourth" )[0]

				expect( result ).to.have.length 4
				expect( first.get "order" ).to.equal 0
				expect( second.get "order" ).to.equal 1
				expect( third.get "order" ).to.equal 2
				expect( fourth.get "order" ).to.equal 3

	#
	# Completed list View
	#
	require ["view/Completed"], (CompletedView) ->
		earlierToday = new Date()
		yesterday = new Date()
		prevMonth = new Date()
		now = new Date()

		earlierToday.setSeconds now.getSeconds() - 1
		yesterday.setDate now.getDate() - 1
		prevMonth.setMonth now.getMonth() - 1

		todos = [
			new ToDoModel( { title: "Last month", completionDate: prevMonth } )
			new ToDoModel( { title: "Yesterday", completionDate: yesterday } ),
			new ToDoModel( { title: "An hour ago", completionDate: earlierToday } ),
		]

		view = new CompletedView()

		describe "Completed list view", ->
			it "Should order tasks by reverse chronological order", ->
				result = view.groupTasks todos
				expect(result[0].deadline).to.equal "Earlier today"
				expect(result[1].deadline).to.equal "Yesterday"

				# If 1 and 2 is correct we know that 3 is too.

	require ["model/ScheduleModel", "model/SettingsModel", "momentjs"], (ScheduleModel, SettingsModel, Moment) ->
		describe "Schedule model", ->
			model = settings = null

			beforeEach ->
				model = new ScheduleModel()
				settings = new SettingsModel()

			after ->
				$(".overlay.scheduler").remove()

			it "Should return a new date 3 hours in the future when scheduling for 'later today'", ->
				now = moment()
				newDate = model.getDateFromScheduleOption( "later today", now )

				expect( newDate ).to.exist

				parsedNewDate = moment newDate
				threeHoursInMs = 3 * 60 * 60 * 1000
				expect( parsedNewDate.diff now ).to.equal threeHoursInMs

			it "Should return a new date the same day at 18:00 when scheduling for 'this evening' (before 18.00)", ->
				today = moment()
				today.hour 17
				newDate = model.getDateFromScheduleOption( "this evening", today )

				expect( newDate ).to.exist

				parsedNewDate = moment newDate
				expect( parsedNewDate.hour() ).to.equal 18
				expect( parsedNewDate.day() ).to.equal today.day()

			it "Should set minutes and seconds to 0 when delaying a task to later today", ->

			it "Should return a new date the day after at 18:00 when scheduling for 'tomorrow evening' (after 18.00)", ->
				today = moment()
				today.hour 19
				newDate = model.getDateFromScheduleOption( "this evening", today )

				expect( newDate ).to.exist

				parsedNewDate = moment newDate
				expect( parsedNewDate.hour() ).to.equal 18
				expect( parsedNewDate.dayOfYear() ).to.equal today.dayOfYear() + 1

			it "Should return a new date the day after at 09:00 when scheduling for 'tomorrow'", ->
				today = moment()
				newDate = model.getDateFromScheduleOption( "tomorrow", today )

				expect( newDate ).to.exist

				parsedNewDate = moment newDate
				expect( parsedNewDate.dayOfYear() ).to.equal today.dayOfYear() + 1
				expect( parsedNewDate.hour() ).to.equal 9

			it "Should return a new date 2 days from now at 09:00 when scheduling for 'day after tomorrow'", ->
				today = moment()
				newDate = model.getDateFromScheduleOption "day after tomorrow"

				expect( newDate ).to.exist

				parsedNewDate = moment newDate
				expect( parsedNewDate.dayOfYear() ).to.equal today.dayOfYear() + 2
				expect( parsedNewDate.hour() ).to.equal 9

			it "Should return a new date this following saturday at 10:00 when scheduling for 'this weekend'", ->
				saturday = moment().endOf "week"
				saturday.day(6).hour(settings.get("snoozes").weekend.morning.hour)
				newDate = model.getDateFromScheduleOption( "this weekend", saturday )

				expect( newDate ).to.exist

				parsedNewDate = moment newDate
				expect( parsedNewDate.day() ).to.equal 6
				expect( Math.floor saturday.diff( parsedNewDate, "days", true ) ).to.equal -7
				expect( parsedNewDate.hour() ).to.equal 10

			it "Should return a new date this following monday at 9:00 when scheduling for 'next week'", ->
				monday = moment().startOf "week"
				monday.day(1).hour(settings.get("snoozes").weekday.morning.hour) # Defautl is sunday. Upgrade that to monday.
				newDate = model.getDateFromScheduleOption( "next week", monday )

				expect( newDate ).to.exist

				parsedNewDate = moment newDate
				expect( parsedNewDate.dayOfYear() ).not.to.equal monday.dayOfYear()
				expect( parsedNewDate.day() ).to.equal 1
				expect( Math.floor monday.diff( parsedNewDate, "days", true ) ).to.equal -7
				expect( parsedNewDate.hour() ).to.equal 9

			it "Should return null when scheduling for 'unspecified'", ->
				expect( model.getDateFromScheduleOption "unspecified" ).to.equal null

			describe "converting time", ->
				it "Should should not convert 'This evening' when it's before 18:00 hours", ->
					expect( model.getDynamicTime( "This Evening", moment("2013-01-01 17:59") ) ).to.equal "This Evening"

				it "Should convert 'This evening' to 'Tomorrow eve' when it's after 18:00 hours", ->
					expect( model.getDynamicTime( "This Evening", moment("2013-01-01 18:00") ) ).to.equal "Tomorrow Eve"

				it "Should convert 'Day After Tomorrow' to 'Wednesday' when we're on a monday", ->
					adjustedTime = moment()
					adjustedTime.day "Monday"

					expect( model.getDynamicTime( "Day After Tomorrow", adjustedTime ) ).to.equal "Wednesday"

				it "Should not convert 'This Weekend' when we're on a monday-friday", ->
					monday = moment().day("Monday")
					expect( model.getDynamicTime( "This Weekend", monday ) ).to.equal "This Weekend"

				it "Should convert 'This Weekend' to 'Next Weekend' when we're on a saturday/sunday", ->
					saturday = moment().day("Saturday")
					expect( model.getDynamicTime( "This Weekend", saturday ) ).to.equal "Next Weekend"

			describe "Rounding minutes and seconds", ->
				it "Should not alter minutes and seconds when delaying a task to later today", ->
					now = moment().minute(23)
					newDate = model.getDateFromScheduleOption( "later today", now )
					parsedNewDate = moment newDate

					expect( parsedNewDate.diff(now, "hours") ).to.equal 3
					expect( parsedNewDate.minute() ).to.equal 23

				it "Should set minutes and seconds to 0 when selecting 'this evening'", ->
					now = moment().hour(12).minute(23).second(23)
					newDate = model.getDateFromScheduleOption( "this evening", now )
					parsedNewDate = moment newDate

					expect( parsedNewDate.hour() ).to.equal 18
					expect( parsedNewDate.minute() ).to.equal 0
					expect( parsedNewDate.second() ).to.equal 0

				it "Should set minutes and seconds to 0 when selecting 'tomorrow'", ->
					newDate = model.getDateFromScheduleOption( "tomorrow", moment().minute(23).second(23) )
					parsedNewDate = moment newDate

					expect( parsedNewDate.minute() ).to.equal 0
					expect( parsedNewDate.second() ).to.equal 0

				it "Should set minutes and seconds to 0 when selecting 'day after tomorrow'", ->
					newDate = model.getDateFromScheduleOption( "day after tomorrow", moment().minute(23).second(23) )
					parsedNewDate = moment newDate

					expect( parsedNewDate.minute() ).to.equal 0
					expect( parsedNewDate.second() ).to.equal 0

				it "Should set minutes and seconds to 0 when selecting 'this weekend'", ->
					newDate = model.getDateFromScheduleOption( "this weekend", moment().minute(23).second(23) )
					parsedNewDate = moment newDate

					expect( parsedNewDate.minute() ).to.equal 0
					expect( parsedNewDate.second() ).to.equal 0

				it "Should set minutes and seconds to 0 when selecting 'next week'", ->
					newDate = model.getDateFromScheduleOption( "next week", moment().minute(23).second(23) )
					parsedNewDate = moment newDate

					expect( parsedNewDate.minute() ).to.equal 0
					expect( parsedNewDate.second() ).to.equal 0

	require ["controller/TaskInputController"], (TaskInputController) ->
		describe "Task Input", ->
			taskInput = null
			callback = null

			before ->
				$("body").append("<form id='add-task'><input></form>")
				taskInput = new TaskInputController()

			after ->
				taskInput.view.remove()
				taskInput = null

			describe "view", ->
				it "Should not trigger a 'create-task' event when submitting input, if the input field is empty"
					# Throw error if create-task is triggered
					# Backbone.once( "create-task", -> done new Error "'create-task' event was triggered" )
					# taskInput.view.$el.submit()

					# setTimeout =>
					# 		done()
					# 	, 200

				it "Should trigger a 'create-task' event when submitting actual input"
					# Backbone.once( "create-task", -> done() )

					# taskInput.view.input.val "here's a new task"
					# taskInput.view.$el.submit()

					# @timeout 200

			describe "controller", ->
				describe "parsing tags", ->
					it "Should be able to add tasks without tags", ->
						taskInput.createTask "I love not using tags"
						model = swipy.todos.findWhere { title: "I love not using tags" }
						expect( model ).to.exist
						expect( model.get "tags" ).to.have.length 0

					it "Should be able to parse 1 tag", ->
						result = taskInput.parseTags "I love #tags"
						expect(result).to.have.length 1
						expect(result[0]).to.equal "tags"

					it "Should be able to parse multiple tags", ->
						result = taskInput.parseTags "I love #tags, #racks, #stacks"
						expect(result).to.have.length 3
						expect(result).to.include "tags"
						expect(result).to.include "racks"
						expect(result).to.include "stacks"

					it "Should be able to parse tags with spaces", ->
						result = taskInput.parseTags "I love #tags, #racks and stacks"
						expect(result).to.have.length 2
						expect(result).to.include "tags"
						expect(result).to.include "racks and stacks"

					it "Should be able to seperate tags without commas", ->
						result = taskInput.parseTags "I love #tags, #racks #stacks"
						expect(result).to.have.length 3
						expect(result).to.include "tags"
						expect(result).to.include "racks"
						expect(result).to.include "stacks"

				describe "parsing title", ->
					it "Should not be able to add tags without a title", ->
						lengthBefore = swipy.todos.length
						taskInput.createTask "#just a tag"
						lengthAfter = swipy.todos.length
						expect( lengthBefore ).to.equal lengthAfter


					it "Should parse title without including 1 tag", ->
						result = taskInput.parseTitle "I love #tags"
						expect(result).to.equal "I love"

					it "Should parse title without including multiple tags", ->
						result = taskInput.parseTitle "I also love #tags, #rags"
						expect(result).to.equal "I also love"

					# it "Should parse title if it's defined after tags"

				it "Should add a new item to swipy.todos list when create-task event is fired", ->
					Backbone.trigger( "create-task", "Test task #tags, #rags" )
					model = swipy.todos.findWhere { "title": "Test task" }
					expect( model ).to.exist
					expect( model.get "tags" ).to.have.length 2
					expect( model.get "tags" ).to.include "tags"
					expect( model.get "tags" ).to.include "rags"

	require ["view/editor/TaskEditor"], (TaskEditor) ->
		describe "Task Editor", ->
			editor = renderSpy = null
			model = new ToDoModel helpers.getDummyModels()[0]

			beforeEach ->
				# Set up the spy. Needs to happen before view is created.
				renderSpy = sinon.spy( TaskEditor.prototype, "render" )
				editor = new TaskEditor { model: model }

			afterEach ->
				# Unwrap the spy
				TaskEditor.prototype.render.restore()
				editor?.remove()
				editor = null

			it "Should pop up the scheduler when clicking scheduled time, so that the user can easily reschedule", ->
				schedulerTrigged = no
				Backbone.on "show-scheduler", -> schedulerTrigged = yes

				editor.$el.find("time").click()

				require ["view/scheduler/ScheduleOverlay"], (ScheduleOverlayView) ->
					_.defer ->
						expect( schedulerTrigged ).to.be.true
						expect( swipy.scheduler.view.shown ).to.be.true

			it "Should re-render the HTML of the editor when the schedule is changed", ->
				expect( renderSpy ).to.have.been.calledOnce

				# Update schedule to 1 day in the future
				model.unset( "schedule", { silent: yes } )
				future = new Date()
				future.setDate( future.getDate() + 1 )
				model.set( "schedule", future )

				expect( renderSpy ).to.have.been.calledTwice

			it "Should remain in the task editor after changing the schedule"

			it "Should set/clear the repeat option when picking one"
			it "Should throw an error message if the changes can't be saved to the server"

	###

	describe "Repeating tasks", ->
		describe "Repeat Picker user interface", ->
			it "Should change the models repeatOption and repeatDate properties when clicking a repeat option", (done) ->
				targetModel = swipy.todos.getActive()[0]
				targetModel.set( "repeatOption", "never" )
				swipy.router.navigate( "edit/#{ targetModel.cid }", yes )

				require ["view/editor/TaskEditor"], ->
					expect( targetModel.get "repeatOption" ).to.equal "never"
					expect( targetModel.get "repeatDate" ).to.be.falsy
					expect( targetModel.get "repeatCount" ).to.equal 0

					editor = swipy.viewController.currView.$el
					editor.find(".repeat-picker a").filter( -> $(@).data( "option" ) is "every day" ).click()

					expect( targetModel.get "repeatOption" ).to.equal "every day"
					done()

			it "Should update the UI when the models repeatOption prop changes", (done) ->
				targetModel = swipy.todos.getActive()[0]
				targetModel.set( "repeatOption", "never" )
				swipy.router.navigate( "edit/#{ targetModel.cid }", yes )

				require ["view/editor/TaskEditor"], ->
					editor = swipy.viewController.currView.$el
					targetModel.set( "repeatOption", "every week" )
					expect( editor.find("a[data-option='every week']").hasClass "selected" ).to.be.true
					done()

		describe "Setting and changing repeat options on ToDo Model ", ->
			task = null
			beforeEach -> task = new ToDoModel()
			afterEach -> task.destroy()

			it "Should create a repeatDate, if it doesn't already exist when the repeatOption is set to something other than 'never'", ->
				expect( task.get "repeatDate" ).to.be.falsy
				task.set( "repeatOption", "every day" )
				expect( task.get "repeatDate" ).to.exist

			it "Should change the repeatDate, if it already exists when the repeatOption is set to something other than 'never'", ->
				task.set( "repeatOption", "every day" )
				originalRepeatDate = task.get "repeatDate"

				task.set( "repeatOption", "every week" )
				expect( originalRepeatDate.getTime() ).to.not.equal task.get( "repeatDate" ).getTime()

			it "Should delete any existing repeatDate when setting repeatOption to 'never'", ->
				task.set( "repeatOption", "every day" )
				task.set( "repeatOption", "never" )
				expect( task.get "repeatDate" ).to.be.falsy

			it "Should not update the repeatDate, repeatCount or repeatOption if schedule changes after a completionDate has been set – Or should it???"

			describe "updating repeatDate", ->
				it "When changing schedule to 11/12/2013 and with a repeatOption of 'every day' the new repeatDate should be 11/13/2013", ->
					task.set( "schedule", new Date("11/12/2013") )
					task.set( "repeatOption", "every day" )

					repeatDate = task.get "repeatDate"
					expect( repeatDate.getMonth() ).to.equal 10
					expect( repeatDate.getDate() ).to.equal 13
					expect( repeatDate.getFullYear() ).to.equal 2013

				it "When changing schedule to 11/12/2013 and with a repeatOption of 'every week' the new repeatDate should be 11/19/2013", ->
					task.set( "schedule", new Date("11/12/2013") )
					task.set( "repeatOption", "every week" )

					repeatDate = task.get "repeatDate"
					expect( repeatDate.getMonth() ).to.equal 10
					expect( repeatDate.getDate() ).to.equal 19
					expect( repeatDate.getFullYear() ).to.equal 2013,

				it "When changing schedule to 11/12/2013 and with a repeatOption of 'every month' the new repeatDate should be 12/12/2013", ->
					task.set( "schedule", new Date("11/12/2013") )
					task.set( "repeatOption", "every month" )

					repeatDate = task.get "repeatDate"
					expect( repeatDate.getMonth() ).to.equal 11
					expect( repeatDate.getDate() ).to.equal 12
					expect( repeatDate.getFullYear() ).to.equal 2013

				it "When changing schedule to 11/12/2013 and with a repeatOption of 'every year' the new repeatDate should be 11/12/2014", ->
					task.set( "schedule", new Date("11/12/2013") )
					task.set( "repeatOption", "every year" )

					repeatDate = task.get "repeatDate"
					expect( repeatDate.getMonth() ).to.equal 10
					expect( repeatDate.getDate() ).to.equal 12
					expect( repeatDate.getFullYear() ).to.equal 2014

				describe "handling difference in month lengths", ->
					it "When changing schedule to 10/31/2013 and with a repeatOption of 'every month' the new repeatDate should be 11/30/2013", ->
						task.set( "schedule", new Date("10/31/2013") )
						task.set( "repeatOption", "every month" )

						repeatDate = task.get "repeatDate"
						expect( repeatDate.getMonth() ).to.equal 10
						expect( repeatDate.getDate() ).to.equal 30
						expect( repeatDate.getFullYear() ).to.equal 2013

			it "Should delete duplicated (repeated) tasks when repeatOption is changed, before creating new ones (Gøres let med en pointer til original task og et event dispatch ved ændring af repeatDate)"

		describe "Duplicating tasks", ->
			task = duplicate = null
			beforeEach ->
				task = new ToDoModel
					title: "test title"
					notes: "test notes"
					tags: ["tag1", "tag2"]
					order: 2
					state: "completed"
					repeatOption: "every day"

				task.set( "completionDate", new Date() )

				duplicate = task.getRepeatableDuplicate()
			afterEach ->
				task.destroy()
				duplicate.destroy()

			it "Shouldn't allow you to create a duplicate, if the task has no repeatDate", ->
				expect( new ToDoModel().getRepeatableDuplicate ).to.throw Error

			it "Should return a new instance of ToDo Model when calling 'getRepeatableDuplicate()'", ->
				expect( task ).to.respondTo "getRepeatableDuplicate"
				expect( duplicate ).to.be.instanceOf ToDoModel

			it "Should retain title when duplicating a task", ->
				expect( task.get "title" ).to.have.length.above 0
				expect( task.get "title" ).to.equal duplicate.get "title"

			it "Should retain tags when duplicating a task", ->
				expect( task.get "tags" ).to.have.length.above 0
				expect( task.get "tags" ).to.have.length duplicate.get("tags").length

			it "Should retain notes when duplicating a task", ->
				expect( task.get "notes" ).to.have.length.above 0
				expect( task.get "notes" ).to.equal duplicate.get "notes"

			it "Should retain order when duplicating a task", ->
				expect( task.get "order" ).to.not.be.falsy
				expect( task.get "order" ).to.equal duplicate.get "order"

			it "Should retain repeatOption when duplicating a task", ->
				expect( task.get "repeatOption" ).to.equal duplicate.get "repeatOption"

			it "Should NOT retain state when duplicating a task", ->
				expect( duplicate.has "state" ).to.be.false
				expect( duplicate.getState() ).to.equal "scheduled"

			it "Should NOT retain model ID when duplicating a task", ->
				if task.id? then expect( duplicate.id ).to.not.exist

			it "Should NOT retain schedule when duplicating a task", ->
				expect( duplicate.has "schedule" ).to.be.true
				expect( task.get( "schedule" ).getTime() ).to.not.equal duplicate.get( "schedule" ).getTime()

			it "Should NOT retain scheduleStr when duplicating a task", ->
				expect( duplicate.has "scheduleStr" ).to.be.true
				expect( task.get( "scheduleStr" ) ).to.not.equal duplicate.get( "scheduleStr" )

			it "Should NOT retain completionDate when duplicating a task", ->
				expect( duplicate.has "completionDate" ).to.be.false

			it "Should NOT retain completionStr when duplicating a task", ->
				expect( duplicate.has "completionStr" ).to.be.false

			it "Should NOT retain completionTimeStr when duplicating a task", ->
				expect( duplicate.has "completionTimeStr" ).to.be.false

			it "Should NOT retain repeatDate when duplicating a task", ->
				expect( duplicate.has "repeatDate" ).to.be.true
				expect( task.get( "repeatDate" ).getTime() ).to.not.equal duplicate.get( "repeatDate" ).getTime()

			it "Should NOT retain repeatCount when duplicating a task", ->
				expect( task.has "repeatCount" ).to.be.true
				expect( duplicate.has "repeatCount" ).to.be.true
				expect( task.get "repeatCount" ).to.not.equal duplicate.get "repeatCount"

			it "Should update repeatCount++ every time a the same task is duplicated/repeated", ->
				expect( duplicate.get "repeatCount" ).to.equal ( task.get( "repeatCount" ) + 1 )

		describe "Duplicating a task based on repeatDate and repeatOption", ->
			task = null
			beforeEach -> task = new ToDoModel( title: "test repeated every day" )
			afterEach -> task.destroy()

			describe "Repeat option: 'every day' — Scheduled for 11/11/2013", ->
				beforeEach ->
					task.set { repeatOption: "every day", schedule: new Date "11/11/2013" }

				it "Should schedule duplicated task for 11/12/2013, if current task is completed 11/11/2013", ->
					task.set( "completionDate", new Date "11/11/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 12
					expect( newSchedule.getFullYear() ).to.equal 2013

				it "Should schedule duplicated task for 11/13/2013, if current task is completed 11/12/2013 (Completed one day too late)", ->
					task.set( "completionDate", new Date "11/12/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 13
					expect( newSchedule.getFullYear() ).to.equal 2013

				it "Should schedule duplicated task for 11/12/2013, if current task is completed 11/09/2013 (Completed too early, don't create new repeat before scheduled repeatDate)", ->
					task.set( "completionDate", new Date "11/09/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( task.get( "schedule" ).getTime() ).to.equal new Date( "11/11/2013" ).getTime()
					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 12
					expect( newSchedule.getFullYear() ).to.equal 2013

				it "Should schedule duplicated task for 01/23/2014, if current task is completed 01/22/2014 (Completed much too late)", ->
					task.set( "completionDate", new Date "01/22/2014" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 0
					expect( newSchedule.getDate() ).to.equal 23
					expect( newSchedule.getFullYear() ).to.equal 2014

			describe "Repeat option: 'mon-fri or sat+sun'", ->
				beforeEach -> task.set { repeatOption: "mon-fri or sat+sun", schedule: new Date "11/11/2013" }

				it "should schedule duplicated task for tuesday 11/12/2013 if scheduled for monday 11/11/2013, but completed sunday 11/10/2013 (Too early)", ->
					task.set( "completionDate", new Date "11/10/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 12
					expect( newSchedule.getFullYear() ).to.equal 2013

				it "should schedule duplicated task for monday 11/18/2013 if completed friday 11/15/2013, but scheduled for monday 11/11/2013 (Too late)", ->
					task.set( "completionDate", new Date "11/15/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 18
					expect( newSchedule.getFullYear() ).to.equal 2013

				it "should schedule duplicated task for tuesday 11/12/2013 if completed and scheduled for monday 11/11/2013 (On time)", ->
					task.set( "completionDate", new Date "11/11/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 12
					expect( newSchedule.getFullYear() ).to.equal 2013

				it "should schedule duplicated task for saturday 11/16/2013 if scheduled for sunday 11/10/2013, but completed sunday 11/03/2013 (A week too early)", ->
					task.set( "schedule", new Date "11/10/2013" )
					task.set( "completionDate", new Date "11/03/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 16
					expect( newSchedule.getFullYear() ).to.equal 2013

				it "should schedule duplicated task for saturday 11/16/2013 if completed sunday 11/10/2013, but scheduled for monday 11/03/2013 (A week too late)", ->
					task.set( "schedule", new Date "11/03/2013" )
					task.set( "completionDate", new Date "11/10/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 16
					expect( newSchedule.getFullYear() ).to.equal 2013

				it "should schedule duplicated task for sunday 11/10/2013 if completed and scheduled for saturday 11/09/2013 (On time)", ->
					task.set( "schedule", new Date "11/09/2013" )
					task.set( "completionDate", new Date "11/09/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 10
					expect( newSchedule.getFullYear() ).to.equal 2013

				it "should schedule duplicated task for saturday 11/16/2013 if completed and scheduled for sunday 11/10/2013 (On time)", ->
					task.set( "schedule", new Date "11/10/2013" )
					task.set( "completionDate", new Date "11/10/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 16
					expect( newSchedule.getFullYear() ).to.equal 2013

			describe "Repeat option: 'every week'", ->
				beforeEach -> task.set { repeatOption: "every week", schedule: new Date "11/12/2013" }

				it "should schedule duplicated task for tuesday 11/19/2013 if current task is scheduled for and completed 11/12/2013 (on time)", ->
					task.set( "completionDate", new Date "11/12/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 19
					expect( newSchedule.getFullYear() ).to.equal 2013

				it "should still schedule duplicated task for tuesday 11/19/2013 if current task is scheduled for 11/12/2013 but completed 11/13/2013 (wednesday, the day after)", ->
					task.set( "completionDate", new Date "11/13/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 19
					expect( newSchedule.getFullYear() ).to.equal 2013

				it "should schedule duplicated task for tuesday 11/19/2013 if current task is scheduled for 11/12/2013 but completed 11/18/2013 (monday, the week after original schedule date)", ->
					task.set( "completionDate", new Date "11/18/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 19
					expect( newSchedule.getFullYear() ).to.equal 2013

				it "should schedule duplicated task for tuesday 11/26/2013 if current task is scheduled for 11/12/2013 but completed wednesday 11/20/2013 (1 week and 1 day after original schedule date)", ->
					task.set( "completionDate", new Date "11/20/2013" )
					duplicate = task.getRepeatableDuplicate()
					newSchedule = duplicate.get "schedule"

					expect( newSchedule.getMonth() ).to.equal 10
					expect( newSchedule.getDate() ).to.equal 26
					expect( newSchedule.getFullYear() ).to.equal 2013

			describe "Repeat option: 'every month'", ->
				it "if repeatDate is 11/18/2013, it should create a duplicate task, scheduled for that day, if current task is completed before 11/18/2013"
				it "if repeatDate is 11/18/2013, it should create a duplicate task, scheduled for 12/18/2013, if current task is completed after 11/18/2013"
				it "if repeatDate is 12/31/2013, it should create a duplicate task, scheduled for 01/30/2014 — Handling the difference between number of days in a month nicely"

			describe "Repeat option: 'every year'", ->
				it "if repeatDate is 11/18/2014, it should create a duplicate task, scheduled for that day, if current task is completed before 11/18/2014"
				it "if repeatDate is 11/18/2014, it should create a duplicate task, scheduled for 12/18/2015, if current task is completed after 11/18/2014"
				it "if repeatDate is only existant because of a leap year, we should schedule for the day before"
					# 29. feb hver 4. år — Og altid den 29. feb.

		describe "Un-setting repeat options on ToDo Model", ->
			it "Should change repeatDate to 'null' of repeatOption is set to 'never'", ->
				task = new ToDoModel( repeatOption: "every week" )
				expect( task.get "repeatDate" ).to.be.instanceOf Date
				task.set( "repeatOption", "never" )
				expect( task.get "repeatDate" ).to.equal null
			it "Should delete duplicated (repeated) tasks when repeatOption is set to 'never'"

		describe "Completing a task with repeat set and automatically spawning a new task", ->
			it "TodoCollection should listen for tasks that are completed and spawn a duplicate if repeatOption is anything but 'never'", (done) ->
				require ["collection/ToDoCollection"], (ToDoCollection) ->
					spawnSpy = sinon.spy( ToDoCollection.prototype, "spawnRepeatTask" )

					expect( spawnSpy ).to.not.have.been.called

					todoCollection = new ToDoCollection()
					todoCollection.add { title: "auto spawn tester", repeatOption: "every day" }

					expect( todoCollection.models ).to.have.length 1

					todoCollection.at(0).set( "completionDate", new Date() )

					expect( spawnSpy ).to.have.been.calledOnce
					expect( todoCollection.models ).to.have.length 2

					# Clean up this mess
					ToDoCollection::spawnRepeatTask.restore()
					todoCollection.off()
					todoCollection = null

					done()

			it "TodoCollection should listen for tasks that are completed and do nothing if repeatOption is 'never'", (done) ->
				require ["collection/ToDoCollection"], (ToDoCollection) ->
					spawnSpy = sinon.spy( ToDoCollection.prototype, "spawnRepeatTask" )

					todoCollection = new ToDoCollection()
					todoCollection.add { title: "auto spawn tester 2" }
					todoCollection.at(0).set( "completionDate", new Date() )

					expect( spawnSpy ).to.have.been.calledOnce
					expect( todoCollection.models ).to.have.length 1

					# Clean up this mess
					ToDoCollection::spawnRepeatTask.restore()
					todoCollection.off()
					todoCollection = null

					done()



	###

	describe "Tag Filter", ->
		beforeEach ->
			Backbone.trigger( "create-task", "TagTester1 #Nina" )
			Backbone.trigger( "create-task", "TagTester2 #Nina, #Pinta" )
			Backbone.trigger( "create-task", "TagTester3 #Nina, #Pinta, #Santa-Maria" )

		afterEach ->
			swipy.todos.findWhere( title: "TagTester1" ).destroy()
			swipy.todos.findWhere( title: "TagTester2" ).destroy()
			swipy.todos.findWhere( title: "TagTester3" ).destroy()

		it "Should add new tags to the global tags collection", ->
			swipy.sidebar.tagFilter.addTag "My Test Tag zyxvy"
			expect( swipy.tags.pluck "title" ).to.include "My Test Tag zyxvy"

		it "Should re-render whenever tags in the global collection are added or removed", ->
			require ["view/sidebar/TagFilter"], (TagFilter) ->
				renderSpy = sinon.spy( TagFilter.prototype, "render" )
				filter = new TagFilter { el: $( ".sidebar .tags-filter" ) }

				# Filter renders automatically upon instantiation
				expect( renderSpy ).to.have.been.calledOnce

				# Set up unique dummy title
				dummyTitle = "dummy-" + new Date().getTime()

				# Render should be called after a new tag was added
				swipy.tags.add { title: dummyTitle }
				expect( renderSpy ).to.have.been.calledTwice

				# Render should be called after a tag was removed
				swipy.tags.remove swipy.tags.findWhere { title: dummyTitle }
				expect( renderSpy ).to.have.been.calledThrice

				TagFilter.prototype.render.restore()
				filter.remove()
				$(".sidebar").append "<section class='tags-filter'><ul class='rounded-tags'></ul></section>"

		it "Should show all tags again if the last tag is de-selected", (done) ->
			require ["view/sidebar/TagFilter"], (TagFilter) ->
				# We disable the render method on swipys tagFilter, as it will react to our events and mess up the call counts
				savedRender = swipy.sidebar.tagFilter.__proto__.render
				swipy.sidebar.tagFilter.render = ->

				renderSpy = sinon.spy( TagFilter.prototype, "render" )
				filter = new TagFilter { el: $( ".sidebar .tags-filter" ) }

				# Filter renders automatically upon instantiation
				expect( renderSpy ).to.have.been.calledOnce

				# Get original tag count
				origTagCount = filter.$el.find("li:not(.tag-input)").length

				# Do a top level filter. Only 1 tag selected.
				Backbone.trigger( "apply-filter", "tag", "Santa-Maria" )
				Backbone.trigger( "remove-filter", "tag", "Santa-Maria" )
				_.defer ->

					expect( renderSpy ).to.have.been.calledThrice
					tags = ( $(tag).text() for tag in filter.$el.find("li:not(.tag-input)") )
					expect( tags ).to.have.length origTagCount

					# Remove spy
					TagFilter.prototype.render.restore()

					# Reset HTML
					filter.remove()
					$(".sidebar").append "<section class='tags-filter'><ul class='rounded-tags'></ul></section>"

					# Re-enable render method on swipys tagFilter
					swipy.sidebar.tagFilter.render = savedRender
					done()

		describe "Filtering tasks", ->
			it "If one or more tags are selected, it should only show the tasks that has all of those filters", ->

				# Make sure we have our 3 tasks all set up
				taskTitles = swipy.todos.pluck "title"
				expect( taskTitles ).to.include "TagTester1"
				expect( taskTitles ).to.include "TagTester2"
				expect( taskTitles ).to.include "TagTester3"

				# Make sure we have our 3 tags all set up
				tagTitles = swipy.tags.pluck "title"
				expect( tagTitles ).to.include "Nina"
				expect( tagTitles ).to.include "Pinta"
				expect( tagTitles ).to.include "Santa-Maria"

				# Filter for first tag. None of the 3 tasks should be rejected.
				Backbone.trigger( "apply-filter", "tag", "Nina" )
				expect( swipy.todos.where { rejectedByTag: no } ).to.have.length 3

				# Filter for second tag. TagTester1 should be rejected
				Backbone.trigger( "apply-filter", "tag", "Pinta" )
				expect( swipy.todos.where { rejectedByTag: no } ).to.have.length 2
				expect( swipy.todos.findWhere( { title: "TagTester1" } ).get "rejectedByTag" ).to.be.true

				# Filter for second tag. TagTester1 and TagTester2 should be rejected
				Backbone.trigger( "apply-filter", "tag", "Santa-Maria" )
				expect( swipy.todos.where { rejectedByTag: no } ).to.have.length 1
				expect( swipy.todos.findWhere( { title: "TagTester2" } ).get "rejectedByTag" ).to.be.true

		describe "Narrowing down available tags after filtering", ->
			it "If one or more tags are selected, it should only show those remaining tags that will allow you to do a deeper filter. No tag should ever leed to 0 results when selected.", (done) ->
				require ["view/sidebar/TagFilter"], (TagFilter) ->
					# We disable the render method on swipys tagFilter, as it will react to our events and mess up the call counts
					savedRender = swipy.sidebar.tagFilter.__proto__.render
					swipy.sidebar.tagFilter.render = ->

					renderSpy = sinon.spy( TagFilter.prototype, "render" )
					filter = new TagFilter { el: $( ".sidebar .tags-filter" ) }

					# Filter renders automatically upon instantiation
					expect( renderSpy ).to.have.been.calledOnce

					# Do a top level filter. Only 1 tag selected.
					console.clear()
					Backbone.trigger( "apply-filter", "tag", "Nina" )
					_.defer ->
						expect( renderSpy ).to.have.been.calledTwice

						# tags is an array of the text content found inside every <li> in the HTML for the filter. This represents real DOM elements,
						# but in a way that's easier to work with.
						tags = ( $(tag).text() for tag in filter.$el.find("li:not(.tag-input)") )

						expect( tags ).to.have.length 3
						expect( tags ).to.contain "Nina"
						expect( tags ).to.contain "Pinta"
						expect( tags ).to.contain "Santa-Maria"

						# Do a deeper filter — Both #Nina & #Pinta are now selected.
						# It should render the same result as above ...
						Backbone.trigger( "apply-filter", "tag", "Pinta" )
						_.defer ->
							tags = ( $(tag).text() for tag in filter.$el.find("li:not(.tag-input)") )

							expect( tags ).to.have.length 3
							expect( tags ).to.contain "Nina"
							expect( tags ).to.contain "Pinta"
							expect( tags ).to.contain "Santa-Maria"

							# Do another deep filter — #Pinta & #Santa-Maria are now selected.
							Backbone.trigger( "remove-filter", "tag", "Nina" )
							Backbone.trigger( "apply-filter", "tag", "Santa-Maria" )
							_.defer ->
								expect( swipy.filter.tagsFilter ).to.have.length 2
								expect( swipy.filter.tagsFilter ).to.contain "Pinta"
								expect( swipy.filter.tagsFilter ).to.contain "Santa-Maria"

								tags = ( $(tag).text() for tag in filter.$el.find("li:not(.tag-input)") )

								expect( tags ).to.have.length 3
								expect( tags ).to.contain "Nina"
								expect( tags ).to.contain "Pinta"
								expect( tags ).to.contain "Santa-Maria"

								# Do another deep filter — #Nina, #Pinta & #Santa-Maria are now selected.
								Backbone.trigger( "apply-filter", "tag", "Nina" )
								_.defer ->
									expect( swipy.filter.tagsFilter ).to.have.length 3
									expect( swipy.filter.tagsFilter ).to.contain "Nina"
									expect( swipy.filter.tagsFilter ).to.contain "Pinta"
									expect( swipy.filter.tagsFilter ).to.contain "Santa-Maria"

									tags = ( $(tag).text() for tag in filter.$el.find("li:not(.tag-input)") )

									expect( tags ).to.have.length 3
									expect( tags ).to.contain "Nina"
									expect( tags ).to.contain "Pinta"
									expect( tags ).to.contain "Santa-Maria"

									# Remove spy
									TagFilter.prototype.render.restore()

									# Reset HTML
									filter.remove()
									$(".sidebar").append "<section class='tags-filter'><ul class='rounded-tags'></ul></section>"

									# Re-enable render method on swipys tagFilter
									swipy.sidebar.tagFilter.render = savedRender
									done()

	require ["view/list/TagEditorOverlay"], (TagEditorOverlay) ->
		describe "Tag Editor overlay", ->
			describe "Marking shared tags selected", ->
				it "Should detect if any tasks have no tags", ->
					data = helpers.getDummyModels()
					models = ( new ToDoModel d for d in data )
					models[0].unset "tags"
					overlay = new TagEditorOverlay { models: models }
					expect(overlay.getTagsAppliedToAll()).to.have.length 0

				it "Should detect if any tags are shared between the selected tasks", ->
					data = [
							title: "Task 1"
							tags: ["tag1", "tag2"]
						,
							title: "Task 2"
							tags: ["tag2"]
						,
							title: "Task 3"
							tags: ["tag2", "tag3"]
					]
					models = ( new ToDoModel d for d in data )
					overlay = new TagEditorOverlay { models: models }

					expect(overlay.getTagsAppliedToAll()).to.have.length 1

			describe "Handling interaction / Updating models", ->
				it "Should detect if clicked tag is currently selected"
				it "Should remove clicked tag from all tasks if clicked tag is marked selected"
				it "Should add clicked tag to all tasks unless tag is marked selected"
				it "Should add new tag to all selected tasks if a new tag is created"

	describe "Router", ->
		before ->
			location.hash = ""
			swipy.router.route( "test/reset", "reset test", -> )

		# Make sure to reset route before each test
		beforeEach ->
			location.hash = "test/reset"
			swipy.router.history = []

		after (done) ->
			swipy.router.once "route:root", -> done()
			location.hash = "test/reset"
			location.hash = ""

		it "Should make sure everything is reset before we start testing routes", ->
			expect( swipy.settings.view ).to.be.undefined

		it "Should trigger appropiate logic when navigating to 'settings'", (done) ->
			eventTriggered = no
			Backbone.once( "show-settings", => eventTriggered = yes )

			location.hash = "settings"

			# Use defer to make sure we've cleared the current event loop
			_.defer ->
				expect( eventTriggered ).to.be.true

				# Give require.js some time to pull in the view
				setTimeout ->
						expect( swipy.settings.view ).to.have.property( "shown", yes )
						done()
					, 500

		it "Should should not open any settings sub view when just navigating to 'settings'", ->
			expect( swipy.settings.view.subview ).to.not.exist

		it "Should trigger appropiate logic when navigating to 'settings/:-id'", (done) ->
			eventTriggered = no
			Backbone.once( "show-settings", => eventTriggered = yes )

			location.hash = "settings/faq"

			_.defer ->
				expect( eventTriggered ).to.be.true
				expect( swipy.settings.view ).to.have.property( "shown", yes )

			# Give require a chance to load in the sub view script first ...
			setTimeout ->
					expect( swipy.settings.view.subview ).to.exist
					expect( swipy.settings.view.subview.$el.hasClass "faq" ).to.be.true
					done()
				, 150

		it "Should trigger appropiate logic when navigating to 'list/:id'", (done) ->
			eventTriggered = no
			Backbone.once( "navigate/view", (id) => if id is "scheduled" then eventTriggered = yes )

			location.hash = "list/scheduled"

			_.defer -> expect( eventTriggered ).to.be.true

			# Give require a chance to load in the list view script first ...
			require ["view/Scheduled"], (ScheduledListView) ->
				setTimeout ->
						expect( swipy.viewController.currView ).to.exist
						expect( swipy.viewController.currView ).to.be.instanceOf ScheduledListView
						done()
					, 150
		it "Should trigger appropiate logic when navigating to 'edit/:id'", (done) ->
			testTaskId = swipy.todos.at(0).cid

			eventTriggered = no
			Backbone.once( "edit/task", (id) => if id is testTaskId then eventTriggered = yes )

			location.hash = "edit/#{ testTaskId }"

			_.defer -> expect( eventTriggered ).to.be.true

			# Give require a chance to load in the list view script first ...
			require ["view/editor/TaskEditor"], (TaskEditor) ->
				setTimeout ->
						expect( swipy.viewController.currView ).to.exist
						expect( swipy.viewController.currView ).to.be.instanceOf TaskEditor
						done()
					, 150


		it "Should go back to list view when calling save on task editor", (done) ->
			# First, set the current route to a todo list, so that we have something to
			# go back to when the editor is saved
			location.hash = "list/todo"

			# Give router a chance to update
			_.defer ->

				# Update route to trigger editor
				editTaskRoute = "edit/#{ swipy.todos.at( 1 ).cid }"
				location.hash = editTaskRoute

				# Then, make sure we've loaded in the editor view
				require ["view/editor/TaskEditor", "view/Todo"], (TaskEditor, TodoList) ->
					setTimeout ->
							editor = swipy.viewController.currView

							expect( swipy.router.history ).to.have.length 2
							expect( editor ).to.be.instanceOf TaskEditor
							expect( $("body").hasClass "edit-mode" ).to.be.true

							# Save editor (Which should trigger a router.back() call on success)
							editor.save().then ->

								# Allow save success callbacks to do their thing first ...
								setTimeout ->
										newRoute = location.hash[1...]

										expect( newRoute ).to.not.equal editTaskRoute
										expect( swipy.viewController.currView ).to.exist
										expect( Backbone.history.fragment ).to.equal "list/todo"
										expect( swipy.viewController.currView ).to.be.instanceOf TodoList
										expect( $("body").hasClass "edit-mode" ).to.be.false

										done()
									, 150
						, 500

		it "Should have a catch-all which results in 'list/todo'", ->
			eventTriggered = no
			Backbone.once( "navigate/view", (id) => if id is "todo" then eventTriggered = yes )

			location.hash = "random/jibberish"

			_.defer ->
				expect( eventTriggered ).to.be.true

		it "The router should have a custom history lookup, so we can call swipy.router.back() and make sure not to go outside our current domain, unlike history.back in the browser", (done) ->
			expect( swipy.router ).to.respondTo "back"
			expect( swipy.router ).to.have.property "history"


			lastRouteDfd = new $.Deferred()
			routerTriggeredTimes = 0
			Backbone.on( "navigate/view edit/task show-settings", -> routerTriggeredTimes++ )

			testRoutes = ["", "list/scheduled", "edit/#{swipy.todos.at(0).cid}", "list/scheduled", "list/completed", "", "settings"]

			for route, i in testRoutes
				do ->
					# Save refs so they aren't overwritten in next loop iteration
					count = i
					path = route

					setTimeout ->
							if count is 0
								# Reset router history
								swipy.router.history = []

							location.hash = path
							if count is testRoutes.length - 1
								setTimeout( lastRouteDfd.resolve, 100 )
						, i * 200

			lastRouteDfd.promise().done ->
				expect( routerTriggeredTimes ).to.equal testRoutes.length
				expect( swipy.router.history ).to.have.length testRoutes.length

				fixRoute = (route) -> if route is "" then return "list/todo" else return route

				expect( location.hash ).to.equal "#" + fixRoute testRoutes[testRoutes.length - 1]

				window.dontdontstopmenow = yes
				swipy.router.back()
				expect( location.hash ).to.equal "#" + fixRoute testRoutes[testRoutes.length - 2]

				swipy.router.back()

				# Make sure backbone.hisotry is also in sync
				expect( Backbone.history.fragment ).to.equal fixRoute testRoutes[testRoutes.length - 3]

				done()

	###
