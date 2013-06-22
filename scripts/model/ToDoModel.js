(function() {
  define(['backbone'], function(Backbone) {
    return Backbone.Model.extend({
      defaults: {
        state: 'todo',
        title: '',
        alert: null,
        tags: null
      }
    });
  });

}).call(this);
