define ["underscore", "view/Default", "text!templates/todo-list.html"], (_, DefaultView, ToDoListTmpl) ->
	DefaultView.extend
		events:
			if Modernizr.touch then "tap" else "click "
		init: ->
			# Set HTML tempalte for our list
			@template = _.template ToDoListTmpl

			# Store subviews in this array so we can kill them (and free up memory) when we no longer need them
			@subviews = []

			# Render the list whenever it updates
			#swipy.collection.on "change", @renderList, @
		render: ->
			@renderList()
			return @
		groupTasks: (collection) ->
			tasksByDate = collection.groupBy (m) -> m.get "scheduleString"
			return ( { deadline, tasks } for deadline, tasks of tasksByDate )
		getDummyData: ->
			[
					title: "Follow up on Martin"
					order: 0
					schedule: new Date("September 16, 2013 16:30:02")
					completionDate: null
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
					schedule: new Date("March 1, 2014 16:30:02")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					#tags: ["Personal", "Bike", "Outside"]
					notes: ""
				,
					title: "Renew Wired Magazine subscription"
					order: 3
					schedule: new Date("September 14, 2013 20:30:02")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["Personal", "Home"]
					notes: ""
				,
					title: "Get a Haircut"
					order: 4
					schedule: new Date("September 14, 2013 23:59:02")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					#tags: ["Errand", "Home"]
					notes: ""
				,
					title: "Clean up the house"
					order: 5
					schedule: new Date("September 15, 2013 16:30:02")
					completionDate: null
					repeatOption: "never"
					repeatDate: null
					tags: ["Errand", "City"]
					notes: ""
			]
		renderList: ->
			items = @getDummyData()
			# items = new Backbone.Collection( swipy.collection.getActive() )
			
			col = new Backbone.Collection()
			type = if Modernizr.touch then "Touch" else "Desktop"
			
			# Remove any old HTML
			@$el.empty()

			require ["model/ToDoModel", "view/list/#{type}ListItem"], (Model, ListItemView) =>
				## Swap out this part with localStorage/parse ##
				col.model = Model
				col.add obj for obj in items
				## / Swap out this part with localStorage/parse ##
				
				for group in @groupTasks col
					tasksJSON = _.invoke( group.tasks, "toJSON" )
					$html = $( @template( { title: group.deadline, tasks: tasksJSON } ) )
					list = $html.find "ol"
					
					for m in group.tasks
						list.append new ListItemView({ model: m }).el

					@$el.append $html

				@afterRenderList col

		afterRenderList: (collection) ->
			# Hook for other views
		customCleanUp: ->
			# Unbind all events
			#swipy.collection.off()
			
			view.remove() for view in @subviews
