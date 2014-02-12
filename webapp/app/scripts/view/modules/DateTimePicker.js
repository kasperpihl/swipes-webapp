(function() {
  define(["backbone", "view/modules/Calendar"], function(Backbone, CalendarView) {
    return Backbone.View.extend({
      initialize: function() {
        return this.render();
      },
      render: function() {
        this.calendar = new CalendarView();
        this.$el.append(this.calendar.el);
        return this;
      }
    });
  });

}).call(this);
