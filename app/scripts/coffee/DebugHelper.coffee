define [
	'underscore'
	'backbone'
	], (_, Backbone) ->
	class DebugHelper
		constructor: ->
			@setDummyTodos()
		setDummyTodos: ->
			# Reset collection with dummy data
			swipy.todos.reset @getDummyData()
		getDummyData: ->
			[
					title: "Follow up on Martin"
					order: 0
					schedule: new Date("September 19, 2013 16:30:02")
					completionDate: new Date("September 02, 2013 11:51:34")
					repeatOption: "never"
					repeatDate: null
					tags: ["work", "client"]
					notes: ""
				,
					title: "Make visual research"
					order: 1
					schedule: new Date("October 13, 2013 11:13:00")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["work", "Project y19"]
					notes: ""
				,
					title: "Buy a new Helmet"
					order: 2
					schedule: new Date("March 1, 2017 16:30:02")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					#tags: ["Personal", "Bike", "Outside"]
					notes: ""
				,
					title: "Renew Wired Magazine subscription"
					order: 3
					schedule: new Date("September 17, 2013 20:30:02")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["Personal", "Home"]
					notes: ""
				,
					title: "Get a Haircut"
					order: 4
					schedule: new Date("September 17, 2013 23:59:02")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					#tags: ["Errand", "Home"]
					notes: ""
				,
					title: "Clean up the house"
					order: 5
					schedule: new Date("September 16, 2013 22:30:02")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["Errand", "City"]
					notes: ""
			]
		