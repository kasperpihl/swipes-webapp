(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.Model.extend({
      url: "test",
      defaults: {
        snoozes: {
          evening: 18,
          laterTodayDelay: 3,
          startOfWeek: 1,
          startOfWeekend: 6,
          weekday: {
            start: "Monday",
            morning: 9
          },
          weekend: {
            start: "Saturday",
            morning: 10
          }
        },
        hasPlus: false
      }
    });
  });

}).call(this);
