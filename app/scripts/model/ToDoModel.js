(function() {
  define(['backbone'], function(Backbone) {
    return Backbone.Model.extend({
      defaults: {
        title: "",
        order: 0,
        schedule: null,
        completionDate: null,
        repeatOption: "never",
        repeatDate: null,
        tags: null,
        notes: ""
      }
    });
  });

}).call(this);
