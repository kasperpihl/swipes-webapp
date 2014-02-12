(function() {
  var __slice = [].slice;

  define(["view/settings/BaseSubview", "gsap-draggable", "slider-control", "text!templates/settings-snoozes.html"], function(BaseView, Draggable, SliderControl, Tmpl) {
    return BaseView.extend({
      className: "snoozes",
      events: {
        "click button": "toggleSection",
        "click .day-picker li": "toggleDay"
      },
      initialize: function() {
        BaseView.prototype.initialize.apply(this, arguments);
        return _.bindAll(this, "updateValue");
      },
      getFloatFromTime: function(hour, minute) {
        return (hour / 24) + (minute / 60 / 24);
      },
      getTimeFromFloat: function(value) {
        var minutesTotal;
        minutesTotal = 1440 * value;
        if (value === 0) {
          return {
            hour: 0,
            minute: 5
          };
        } else if (value === 1) {
          return {
            hour: 23,
            minute: 55
          };
        } else {
          return {
            hour: Math.floor(minutesTotal / 60),
            minute: Math.round(minutesTotal) % 60
          };
        }
      },
      getFormattedTime: function(hour, minute, addAmPm) {
        if (addAmPm == null) {
          addAmPm = true;
        }
        if (minute < 10) {
          minute = "0" + minute;
        }
        if (addAmPm) {
          if (hour === 0 || hour === 24) {
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
          case "start-evening":
            return this.getFloatFromTime(snoozes.weekday.evening.hour, snoozes.weekday.evening.minute);
          case "start-weekend":
            return this.getFloatFromTime(snoozes.weekend.morning.hour, snoozes.weekend.morning.minute);
          case "delay":
            return this.getFloatFromTime(snoozes.laterTodayDelay.hours, snoozes.laterTodayDelay.minutes);
        }
      },
      updateValue: function(sliderId, updateModel) {
        var snoozes, time;
        if (updateModel == null) {
          updateModel = false;
        }
        snoozes = swipy.settings.get("snoozes");
        switch (sliderId) {
          case "start-day":
            time = this.getTimeFromFloat(this.startDaySlider.value);
            snoozes.weekday.morning = time;
            this.$el.find(".day button").text(this.getFormattedTime(time.hour, time.minute));
            break;
          case "start-evening":
            time = this.getTimeFromFloat(this.startEveSlider.value);
            snoozes.weekday.evening = time;
            this.$el.find(".evening button").text(this.getFormattedTime(time.hour, time.minute));
            break;
          case "start-weekend":
            time = this.getTimeFromFloat(this.startWeekendSlider.value);
            snoozes.weekend.morning = time;
            this.$el.find(".weekends button").text(this.getFormattedTime(time.hour, time.minute));
            break;
          case "delay":
            time = this.getTimeFromFloat(this.delaySlider.value);
            snoozes.laterTodayDelay.hours = time.hour;
            snoozes.laterTodayDelay.minutes = time.minute;
            this.$el.find(".later-today button").text("+" + (this.getFormattedTime(time.hour, time.minute, false)) + "h");
        }
        if (updateModel) {
          swipy.settings.unset("snoozes", {
            silent: true
          });
          return swipy.settings.set("snoozes", snoozes);
        }
      },
      setTemplate: function() {
        return this.template = _.template(Tmpl);
      },
      render: function() {
        this.$el.html(this.template({
          snoozes: swipy.settings.get("snoozes")
        }));
        return this.transitionIn();
      },
      toggleSection: function(e) {
        var $parent, el, opts,
          _this = this;
        $parent = $(e.currentTarget.parentNode.parentNode).toggleClass("toggled");
        if ($parent.hasClass("toggled")) {
          if ($parent.hasClass("day")) {
            el = this.el.querySelector(".day .range-slider");
            opts = {
              onDrag: function() {
                return _this.updateValue.apply(_this, ["start-day"].concat(__slice.call(arguments)));
              },
              onDragEnd: function() {
                return _this.updateValue.apply(_this, ["start-day", true].concat(__slice.call(arguments)));
              },
              steps: 25
            };
            if (this.startDaySlider != null) {
              this.startDaySlider.destroy();
            }
            return this.startDaySlider = new SliderControl(el, opts, this.getSliderVal("start-day"));
          } else if ($parent.hasClass("evening")) {
            el = this.el.querySelector(".evening .range-slider");
            opts = {
              onDrag: function() {
                return _this.updateValue.apply(_this, ["start-evening"].concat(__slice.call(arguments)));
              },
              onDragEnd: function() {
                return _this.updateValue.apply(_this, ["start-evening", true].concat(__slice.call(arguments)));
              },
              steps: 25
            };
            if (this.startEveSlider != null) {
              this.startEveSlider.destroy();
            }
            return this.startEveSlider = new SliderControl(el, opts, this.getSliderVal("start-evening"));
          } else if ($parent.hasClass("weekends")) {
            el = this.el.querySelector(".weekends .range-slider");
            opts = {
              onDrag: function() {
                return _this.updateValue.apply(_this, ["start-weekend"].concat(__slice.call(arguments)));
              },
              onDragEnd: function() {
                return _this.updateValue.apply(_this, ["start-weekend", true].concat(__slice.call(arguments)));
              },
              steps: 25
            };
            if (this.startWeekendSlider != null) {
              this.startWeekendSlider.destroy();
            }
            return this.startWeekendSlider = new SliderControl(el, opts, this.getSliderVal("start-weekend"));
          } else if ($parent.hasClass("later-today")) {
            el = this.el.querySelector(".later-today .range-slider");
            opts = {
              onDrag: function() {
                return _this.updateValue.apply(_this, ["delay"].concat(__slice.call(arguments)));
              },
              onDragEnd: function() {
                return _this.updateValue.apply(_this, ["delay", true].concat(__slice.call(arguments)));
              },
              steps: 49
            };
            if (this.delaySlider != null) {
              this.delaySlider.destroy();
            }
            return this.delaySlider = new SliderControl(el, opts, this.getSliderVal("delay"));
          }
        }
      },
      toggleDay: function(e) {
        var dayName, dayNum, snoozes;
        $(".day-picker li").removeClass("selected");
        $(e.currentTarget).addClass("selected");
        dayName = e.currentTarget.getAttribute("data-name");
        dayNum = e.currentTarget.getAttribute("data-num");
        this.$el.find(".week-start-day button").text(dayName);
        snoozes = swipy.settings.get("snoozes");
        snoozes.weekday.startDay = {
          name: dayName,
          number: dayNum
        };
        swipy.settings.unset("snoozes", {
          silent: true
        });
        return swipy.settings.set("snoozes", snoozes);
      },
      cleanUp: function() {
        var _ref, _ref1, _ref2, _ref3;
        if ((_ref = this.startDaySlider) != null) {
          _ref.destroy();
        }
        if ((_ref1 = this.startEveSlider) != null) {
          _ref1.destroy();
        }
        if ((_ref2 = this.startWeekendSlider) != null) {
          _ref2.destroy();
        }
        if ((_ref3 = this.delaySlider) != null) {
          _ref3.destroy();
        }
        return BaseView.prototype.cleanUp.apply(this, arguments);
      }
    });
  });

}).call(this);
