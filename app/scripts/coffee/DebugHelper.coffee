define ->
	class DebugHelper
		constructor: ->
			# @setDummyTodos()
		setDummyTodos: ->
			# Reset collection with dummy data
			swipy.collections.todos.reset @getDummyData()
		getDummyData: ->
			[
					title: "Follow up on Martin"
					schedule: new Date("September 19, 2013 16:30:02")
					completionDate: new Date("September 02, 2013 11:51:34")
					repeatOption: "never"
					repeatDate: null
					tags: ["Work", "Newbizz"]
					notes: ""
				,
					title: "Make visual research for new Swipes design"
					order: 1
					schedule: new Date("September 13, 2013 09:00:00")
					completionDate: new Date("September 13, 2013 11:13:00")
					repeatOption: "never"
					repeatDate: null
					notes: ""
				,
					title: "Buy a new MBT Helmet"
					order: 2
					schedule: null
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["Personal", "Outside"]
					notes: ""
				,
					title: "Introduce the team to new MailChimp"
					schedule: new Date("September 17, 2013 20:30:02")
					completionDate: null
					repeatOption: "never"
					tags: ["Presentation", "Work"]
					repeatDate: null
					notes: ""
				,
					title: "Find a weekend getaway on Kayak.com"
					schedule: new Date("September 16, 2013 22:30:02")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["Adventure"]
					notes: ""
				,
					title: "Prepare the Marketing Workshop"
					schedule: new Date("September 17, 2013 09:00:00")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["Work"]
					notes: ""
				,
					title: "Check that insurance covers bike"
					schedule: new Date("December 1, 2013 09:00:00")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["Chore"]
					notes: ""
				,
					title: "Finalize Swipes Web App"
					schedule: new Date("November 21, 2013 09:00:00")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["Work", "HTML5", "Backbone.js"]
					notes: "Faster, better, stronger — http://swipesapp.com/"
				,
					title: "Learn to make Tiramisú"
					schedule: null
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["Food", "Personal"]
					notes: "There are some great recipes on Epicurious.com!"
				,
					title: "Look up stock prices for LinkedIn"
					schedule: new Date("November 22, 2013 09:00:00")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["Hustling", "Work"]
					notes: "There are some great recipes on Epicurious.com!"
				,
					title: "Pack suitcase for Dublin"
					schedule: new Date("October 27, 2013 18:00:00")
					completionDate: new Date("October 27, 2013 22:00:34")
					repeatOption: "never"
					repeatDate: null
					tags: ["Work"]
					notes: ""
				,
					title: "Prepare pitch for The Web Summit"
					schedule: new Date("October 27, 2013 10:00:00")
					completionDate: new Date("October 27, 2013 14:59:02")
					repeatOption: "never"
					repeatDate: null
					tags: ["Presentaion", "Work"]
					notes: ""
			]
