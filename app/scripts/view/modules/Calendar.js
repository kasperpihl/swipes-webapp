(function() {
  define(["underscore", "backbone", "text!templates/calendar.html", "momentjs", "clndr"], function(_, Backbone, CalendarTmpl) {
    return Parse.View.extend({
      tagName: "div",
      className: "calendar-wrap",
      initialize: function() {
        _.bindAll(this, "handleClickDay", "handleMonthChanged");
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
            onMonthChange: this.handleMonthChanged
          },
          weekOffset: swipy.settings.get("snoozes").weekday.startDay.number,
          doneRendering: this.afterRender,
          adjacentDaysChangeMonth: true,
          constraints: {
            startDay: this.getTodayStr()
          },
          ready: function() {
            return _this.selectDay(_this.today);
          },
          daysOfTheWeek: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        };
      },
      createCalendar: function() {
        return this.clndr = this.$el.clndr(this.getCalendarOpts());
      },
      getTodayStr: function() {
        return new moment().format("YYYY-MM-DD");
      },
      getElementFromMoment: function(moment) {
        var dateStr;
        dateStr = moment.format("YYYY-MM-DD");
        return this.days.filter(function() {
          return $(this).attr("class").indexOf(dateStr) !== -1;
        });
      },
      getTimeObj: function(moment) {
        var day, snoozes;
        snoozes = swipy.settings.get("snoozes");
        day = this.selectedDay.day();
        if (day === 0 || day === 6) {
          return {
            hour: snoozes.weekend.morning.hour,
            minute: snoozes.weekend.morning.minute
          };
        } else {
          return {
            hour: snoozes.weekday.morning.hour,
            minute: snoozes.weekday.morning.minute
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
          this.model.set("time", this.getTimeObj(this.selectedDay));
          return this.model.set("timeEditedBy", "calendar");
        }
      },
      handleClickDay: function(day) {
        if ($(day.element).hasClass("past")) {
          return false;
        }
        return this.selectDay(day.date, day.element);
        /*
        			$el = $ day.element
        			if $el.hasClass "adjacent-month"
        				if $el.hasClass "last-month" then @clndr.back()
        				else @clndr.forward()
        */

      },
      handleMonthChanged: function(moment) {
        var maxDate, newDate, oldDate;
        newDate = moment;
        oldDate = this.selectedDay.date();
        maxDate = newDate.daysInMonth();
        newDate.date(Math.min(oldDate, maxDate));
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
