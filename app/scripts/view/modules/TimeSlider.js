(function() {
  define(["underscore", "backbone", "gsap-draggable", "slider-control", "momentjs"], function(_, Backbone, Draggable, SliderControl) {
    return Backbone.View.extend({
      tagName: "div",
      className: "range-slider lobster",
      initialize: function() {
        _.bindAll(this, "updateValue");
        return this.listenTo(this.model, "change:time", _.debounce(this.updateSlider, 50));
      },
      getFloatFromTime: function(hour, minute) {
        return (hour / 24) + (minute / 60 / 24);
      },
      getTimeFromFloat: function(val) {
        var minutesTotal;
        minutesTotal = 1440 * val;
        if (val < 1) {
          return {
            hour: Math.floor(minutesTotal / 60),
            minute: Math.floor(minutesTotal % 60)
          };
        } else {
          return {
            hour: 23,
            minute: 55
          };
        }
      },
      getOpts: function() {
        return {
          onDrag: this.updateValue,
          onDragEnd: this.updateValue
        };
      },
      getStartVal: function() {
        var day, result, snoozes;
        snoozes = swipy.settings.get("snoozes");
        day = snoozes.weekday;
        result = this.getFloatFromTime(day.morning.hour, day.morning.minute);
        return result;
      },
      updateValue: function() {
        var time;
        if (!this.model.get("userManuallySetTime")) {
          this.model.set("userManuallySetTime", true);
        }
        time = this.getTimeFromFloat(this.slider.value);
        this.model.unset("time", {
          silent: true
        });
        return this.model.set("time", time);
      },
      updateSlider: function(model, time) {
        var value;
        value = this.getFloatFromTime(time.hour, time.minute);
        if (this.slider == null) {
          return this.slider = new SliderControl(this.el, this.getOpts(), value);
        } else {
          return this.slider.setValue(value);
        }
      },
      render: function() {
        this.$el.html("<div class='track'></div><div class='handle'></div>");
        return this;
      },
      remove: function() {
        var _ref;
        this.undelegateEvents();
        this.stopListening();
        if ((_ref = this.slider) != null) {
          _ref.destroy();
        }
        return this.$el.remove();
      }
    });
  });

}).call(this);
