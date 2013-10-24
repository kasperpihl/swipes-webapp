(function() {
  define(["underscore", "backbone", "text!templates/calendar.html", "clndr"], function(_, Backbone, CalendarTmpl) {
    return Backbone.View.extend({
      tagName: "div",
      className: "calendar-wrap",
      initialize: function() {
        this.setTemplate();
        return this.render();
      },
      setTemplate: function() {
        return this.template = _.template(CalendarTmpl);
      },
      render: function() {
        this.$el.html(this.template({}));
        return this;
      }
    });
  });

}).call(this);
