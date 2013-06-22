// Generated by CoffeeScript 1.3.3
(function() {

  define(['collection/ToDoCollection'], function(ToDoCollection) {
    return describe("A ToDo collection", function() {
      ToDoCollection = new ToDoCollection();
      it("shoudl exist", function() {
        return ToDoCollection.should.exist;
      });
      it("should be able to add new todos", function() {
        ToDoCollection.add({
          title: "test todo"
        });
        return ToDoCollection.findWhere({
          title: "test todo"
        }).should.exist;
      });
      it("should be able to return a list of todos", function() {
        ToDoCollection.add({
          title: "test todo"
        });
        ToDoCollection.getActive().should.not.be.undefined;
        return ToDoCollection.findWhere({
          state: "todo",
          title: "test todo"
        }).should.exist;
      });
      it("should be able to return a list of scheduled todos", function() {
        ToDoCollection.add({
          title: "test scheduled todo",
          state: "scheduled"
        });
        ToDoCollection.getScheduled().should.not.be.undefined;
        return ToDoCollection.findWhere({
          state: "scheduled",
          title: "test scheduled todo"
        }).should.exist;
      });
      return it("should be able to return a list of completed totods", function() {
        ToDoCollection.add({
          title: "test archived todo",
          state: "archived"
        });
        ToDoCollection.getArchived().should.not.be.undefined;
        return ToDoCollection.findWhere({
          state: "archived",
          title: "test archived todo"
        }).should.exist;
      });
    });
  });

}).call(this);
