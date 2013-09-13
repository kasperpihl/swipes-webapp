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
        var now,
          _this = this;
        now = new Date().getTime();
        return this.filter(function(m) {
          var schedule;
          schedule = m.get("schedule");
          if (!schedule) {
            return false;
          } else {
            return schedule.getTime() < now;
          }
        });
      },
      getScheduled: function() {
        return this.where({
          schedule: null,
          completionDate: null
        });
      },
      getCompleted: function() {
        var _this = this;
        return this.filter(function(m) {
          return m.get("completionDate") !== null;
        });
      }
    });
  });

}).call(this);