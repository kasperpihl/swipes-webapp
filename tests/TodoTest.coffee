define ['collection/ToDoCollection'], (ToDoCollection) ->
	
	describe "A ToDo collection", ->
		ToDoCollection = new ToDoCollection()

		it "shoudl exist", ->
			ToDoCollection.should.exist

		it "should be able to add new todos", ->
			ToDoCollection.add title: "test todo"
			ToDoCollection.findWhere( title: "test todo" ).should.exist

		it "should be able to return a list of todos", ->
			ToDoCollection.add title: "test todo"
			ToDoCollection.getActive().should.not.be.undefined
			ToDoCollection.findWhere( state: "todo", title: "test todo" ).should.exist

		it "should be able to return a list of scheduled todos", ->
			ToDoCollection.add title: "test scheduled todo", state: "scheduled"
			ToDoCollection.getScheduled().should.not.be.undefined
			ToDoCollection.findWhere( state: "scheduled", title: "test scheduled todo" ).should.exist

		it "should be able to return a list of completed totods", ->
			ToDoCollection.add title: "test archived todo", state: "archived"
			ToDoCollection.getArchived().should.not.be.undefined
			ToDoCollection.findWhere( state: "archived", title: "test archived todo").should.exist

	describe "A ToDo view", ->
		it "should test some stuff", ->
			( 2+2 ).should.equal 4