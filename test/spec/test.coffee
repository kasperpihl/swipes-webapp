
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
				contentHolder.html tmpl( data )
				dfd.resolve()

			return dfd.promise()

	describe "Basics", ->
		it "App should be up and running", ->
			expect( window.app ).to.exist

	require ["model/ToDoModel"], (Model) ->
		describe "List Item model", ->
			it "Should set scheduleStr when instantiated", ->
				expect(2).to.be.lessThan 1 
			it "Should update scheduleStr when schedule property is changed", ->
				expect(2).to.be.lessThan 1

	require ["model/ToDoModel", "view/list/DesktopListItem"], (Model, View) ->
		describe "List Item View", ->
			
			describe "Selection", ->
				it "Should toggle selection when clicked", ->
					model = new Model helpers.getListItemModel()
					helpers.renderTodoList( items: [model.toJSON()] ).then ->
						el = $("#content-holder .todo > li").first()
						view = new View { el, model }

						el.click()

						expect( model.get "selected" ).to.be.true
						expect( el.hasClass "selected" ).to.be.true

						contentHolder.empty()



			