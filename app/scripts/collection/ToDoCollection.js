(function() {
  define(['backbone', 'backbone.localStorage', 'model/ToDoModel'], function(Backbone, BackboneLocalStorage, ToDoModel) {
    return Backbone.Collection.extend({
      model: ToDoModel,
      localStorage: new Backbone.LocalStorage("SwipyTodos"),
      initialize: function() {
        return this.on('add', function(model) {
          return model.save();
        });
      },
      getActive: function() {
        return this.where({
          state: "todo"
        });
      },
      getScheduled: function() {
        return this.where({
          state: "scheduled"
        });
      },
      getCompleted: function() {
        return this.where({
          state: "completed"
        });
      }
    });
  });

}).call(this);
