(function() {
  define(["underscore", "backbone", "js/view/modules/Calendar", "js/view/modules/TimeSlider", "text!templates/datepicker.html"], function(_, Backbone, CalendarView, TimeSliderView, DatePickerTmpl) {
    return Parse.View.extend({
      className: "date-picker",
      initialize: function() {
        this.setTemplate();
        return this.model = new Backbone.Model();
      },
      setTemplate: function() {
        return this.template = _.template(DatePickerTmpl);
      },
      render: function() {
        this.$el.html(this.template({}));
        this.timeSlider = new TimeSliderView({
          model: this.model
        });
        this.calendar = new CalendarView({
          model: this.model
        });
        this.$el.find(".content").append(this.calendar.el).append(this.timeSlider.el);
        this.timeSlider.render();
        this.calendar.render();
        return this;
      }
    });
  });

}).call(this);
