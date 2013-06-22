(function() {
  define(['backbone', 'backbone-localStorage', 'model/ToDoModel'], function(Backbone, BackboneLocalStorage, ToDoModel) {
    return Backbone.Collection.extend({
      model: ToDoModel,
      localStorage: new Backbone.LocalStorage("SwipyTodos"),
      getActive: function() {
        return this.where({
          status: "todo"
        });
      },
      getScheduled: function() {
        return this.where({
          status: "scheduled"
        });
      },
      getArchived: function() {
        return this.where({
          status: "archived"
        });
      }
    });
  });

}).call(this);
