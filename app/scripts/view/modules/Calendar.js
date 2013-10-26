(function() {
  define(["underscore", "backbone", "text!templates/calendar.html", "momentjs", "clndr"], function(_, Backbone, CalendarTmpl) {
    return Backbone.View.extend({
      tagName: "div",
      className: "calendar-wrap",
      initialize: function() {
        _.bindAll(this, "handleClickDay", "handleMonthChanged", "handleYearChanged");
        this.listenTo(this.model, "change:date", this.renderDate);
        this.listenTo(this.model, "change:time", this.renderTime);
        return this.today = moment();
      },
      getCalendarOpts: function() {
        var _this = this;
        return {
          template: CalendarTmpl,
          targets: {
            nextButton: "next",
            previousButton: "previous",
            day: "day"
          },
          clickEvents: {
            click: this.handleClickDay,
            onYearChange: this.handleYearChanged,
            onMonthChange: this.handleMonthChanged
          },
          doneRendering: this.afterRender,
          ready: function() {
            return _this.selectDay(_this.today);
          },
          daysOfTheWeek: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        };
      },
      createCalendar: function() {
        return this.clndr = this.$el.clndr(this.getCalendarOpts());
      },
      getElementFromMoment: function(moment) {
        var dateStr;
        dateStr = moment.format("YYYY-MM-DD");
        return this.days.filter(function() {
          return $(this).attr("id").indexOf(dateStr) !== -1;
        });
      },
      getTimeObj: function(moment) {
        var snoozes;
        snoozes = swipy.settings.get("snoozes");
        if (this.selectedDay.day() < 5) {
          return {
            hour: snoozes.weekday.morning.hour,
            minute: snoozes.weekday.morning.minute
          };
        } else {
          return {
            hour: snoozes.weekend.morning.hour,
            minute: snoozes.weekend.morning.minute
          };
        }
      },
      getFormattedTime: function(hour, minute) {
        if (minute < 10) {
          minute = "0" + minute;
        }
        if (hour === 0 || hour === 24) {
          return "12:" + minute + " AM";
        } else if (hour <= 11) {
          return hour + ":" + minute + " AM";
        } else if (hour === 12) {
          return "12:" + minute + " PM";
        } else {
          return hour - 12 + ":" + minute + " PM";
        }
      },
      selectDay: function(moment, element) {
        this.days = this.$el.find(".day");
        this.days.removeClass("selected");
        if (element == null) {
          element = this.getElementFromMoment(moment);
        }
        $(element).addClass("selected");
        this.selectedDay = moment;
        this.$el.toggleClass("displaying-curr-month", moment.isSame(this.today, "month"));
        this.model.unset("date", {
          silent: true
        });
        this.model.set("date", this.selectedDay);
        if (this.model.get("userManuallySetTime")) {
          return this.renderTime();
        } else {
          return this.model.set("time", this.getTimeObj(this.selectedDay));
        }
      },
      handleClickDay: function(day) {
        var $el;
        if ($(day.element).hasClass("past")) {
          return false;
        }
        this.selectDay(day.date, day.element);
        $el = $(day.element);
        if ($el.hasClass("adjacent-month")) {
          if ($el.hasClass("last-month")) {
            return this.clndr.back();
          } else {
            return this.clndr.forward();
          }
        }
      },
      handleYearChanged: function(moment) {
        return console.log("Switched year to ", moment.year());
      },
      handleMonthChanged: function(moment) {
        var newDate;
        newDate = moment;
        newDate.date(this.selectedDay.date());
        if (newDate.isBefore(this.today)) {
          newDate = this.today;
        }
        return this.selectDay(newDate);
      },
      render: function() {
        this.createCalendar();
        return this;
      },
      renderDate: function() {
        return this.$el.find(".month .selected-date").text(this.selectedDay.format("MMM Do"));
      },
      renderTime: function() {
        var time;
        time = this.model.get("time");
        return this.$el.find(".month time").text(this.getFormattedTime(time.hour, time.minute));
      },
      remove: function() {
        this.undelegateEvents();
        this.stopListening();
        return this.$el.remove();
      }
    });
  });

}).call(this);
