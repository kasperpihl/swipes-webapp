(function() {
  define(["underscore", "backbone", "view/modules/Calendar", "text!templates/datepicker.html"], function(_, Backbone, CalendarView, DatePickerTmpl) {
    return Backbone.View.extend({
      className: "date-picker",
      initialize: function() {
        this.setTemplate();
        return this.render();
      },
      setTemplate: function() {
        return this.template = _.template(DatePickerTmpl);
      },
      render: function() {
        this.$el.html(this.template({}));
        this.calendar = new CalendarView();
        this.$el.find(".content").append(this.calendar.el);
        this.calendar.render();
        return this;
      }
    });
  });

}).call(this);
