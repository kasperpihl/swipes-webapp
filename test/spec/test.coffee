
require ["jquery", "underscore", "backbone"], ($, _, Backbone) ->
	
	contentHolder = $("#content-holder")
	
	helpers = 
		getListItemModel: ->
			title: "Follow up on Martin"
			order: 0
			schedule: new Date()
			completionDate: null
			repeatOption: "never"
			repeatDate: null
			tags: ["work", "client"]
			notes: ""
		renderTodoList: (data) ->
			dfd = new $.Deferred()
			require ["text!templates/todo-list.html"], (ListTempl) ->
				tmpl = _.template ListTempl

				data = 
					taskGroups: [
						{
							deadline: "Tomorrow"
							tasks: [helpers.getListItemModel()] 
						}
					]

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

			it "Should set scheduleStr when instantiated", ->
				expect( model.get("scheduleString") ).to.equal "past"
			
			it "Should update scheduleStr when schedule property is changed", ->
				date = model.get "schedule"

				# unset for change event to occur
				model.set( "schedule", "" )
				
				date.setDate date.getDate()+1
				model.set( "schedule", date )

				expect( model.get("scheduleString") ).to.equal "Tomorrow"

	#
	# To Do View
	#
	require ["model/ToDoModel", "view/list/DesktopListItem"], (Model, View) ->
		describe "List Item View", ->
			
			describe "Selection", ->
				it "Should toggle selection when clicked", ->
					model = new Model helpers.getListItemModel()
					helpers.renderTodoList( items: [model.toJSON()] ).then ->
						el = $("#content-holder .todo ol > li").first()
						view = new View { el, model }

						el.click()

						expect( el ).to.not.be.empty
						expect( model.get "selected" ).to.be.true
						expect( el.hasClass "selected" ).to.be.true

						debugger

						contentHolder.empty()



			