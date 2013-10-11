(function() {
  var __slice = [].slice;

  define(["view/settings/BaseSubview", "gsap-draggable", "slider-control", "text!templates/settings-snoozes.html"], function(BaseView, Draggable, SliderControl, Tmpl) {
    return BaseView.extend({
      className: "snoozes",
      events: {
        "click button": "toggleSection"
      },
      initialize: function() {
        BaseView.prototype.initialize.apply(this, arguments);
        _.bindAll(this, "setupSliders", "updateValue");
        return this.transitionInDfd.then(this.setupSliders);
      },
      getFloatFromTime: function(hour, minute) {
        return (hour / 24) + (minute / 60 / 24);
      },
      getTimeFromFloat: function(val) {
        var minutesTotal;
        minutesTotal = 1440 * val;
        return {
          hour: Math.floor(minutesTotal / 60),
          minute: Math.floor(minutesTotal % 60)
        };
      },
      getFormattedTime: function(hour, minute, addAmPm) {
        if (addAmPm == null) {
          addAmPm = true;
        }
        if (minute < 10) {
          minute = "0" + minute;
        }
        if (addAmPm) {
          if (hour === 0) {
            return "12:" + minute + " AM";
          } else if (hour <= 11) {
            return hour + ":" + minute + " AM";
          } else if (hour === 12) {
            return "12:" + minute + " PM";
          } else {
            return hour - 12 + ":" + minute + " PM";
          }
        } else {
          return hour + ":" + minute;
        }
      },
      getSliderVal: function(sliderId) {
        var snoozes;
        snoozes = swipy.settings.get("snoozes");
        switch (sliderId) {
          case "start-day":
            return this.getFloatFromTime(snoozes.weekday.morning.hour, snoozes.weekday.morning.minute);
        }
      },
      setupSliders: function() {
        var startDayEl, startDayOpts,
          _this = this;
        startDayEl = this.el.querySelector(".day .range-slider");
        startDayOpts = {
          onDrag: function() {
            return _this.updateValue.apply(_this, ["start-day"].concat(__slice.call(arguments)));
          },
          onDragEnd: function() {
            return _this.updateValue.apply(_this, ["start-day"].concat(__slice.call(arguments)));
          }
        };
        return this.startDaySlider = new SliderControl(startDayEl, startDayOpts, this.getSliderVal("start-day"));
      },
      updateValue: function(sliderId) {
        var snoozes, time;
        snoozes = swipy.settings.get("snoozes");
        swipy.settings.unset("snoozes", {
          silent: true
        });
        switch (sliderId) {
          case "start-day":
            time = this.getTimeFromFloat(this.startDaySlider.value);
            this.$el.find(".day button").text(this.getFormattedTime(time.hour, time.minute));
        }
        return swipy.settings.set("snoozes", snoozes);
      },
      setTemplate: function() {
        return this.template = _.template(Tmpl);
      },
      render: function() {
        console.log("Rendering snoozes");
        this.$el.html(this.template({
          snoozes: swipy.settings.get("snoozes")
        }));
        return this.transitionIn();
      },
      toggleSection: function(e) {
        return $(e.currentTarget.parentNode.parentNode).toggleClass("toggled");
      },
      cleanUp: function() {
        this.startDaySlider.destroy();
        return BaseView.prototype.cleanUp.apply(this, arguments);
      }
    });
  });

}).call(this);
