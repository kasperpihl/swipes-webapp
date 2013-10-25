(function() {
  define(["underscore", "backbone", "text!templates/calendar.html", "momentjs", "clndr"], function(_, Backbone, CalendarTmpl) {
    return Backbone.View.extend({
      tagName: "div",
      className: "calendar-wrap",
      initialize: function() {
        _.bindAll(this, "handleClickDay", "handleMonthChanged", "handleYearChanged");
        this.today = moment();
        this.setTemplate();
        return this.render();
      },
      setTemplate: function() {
        return this.template = _.template(CalendarTmpl);
      },
      getCalendarOpts: function() {
        var _this = this;
        return {
          template: CalendarTmpl,
          targets: {
            nextButton: "next",
            previousButton: "previous",
            day: "day",
            empty: "empty"
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
      selectDay: function(moment, element) {
        this.days = this.$el.find(".day");
        this.days.removeClass("selected");
        if (element == null) {
          element = this.getElementFromMoment(moment);
        }
        $(element).addClass("selected");
        return this.selectedDay = moment;
      },
      handleClickDay: function(day) {
        return this.selectDay(day.date, day.element);
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
        console.log("Switched month to ", moment.month());
        return this.selectDay(newDate);
      },
      render: function() {
        this.createCalendar();
        return this;
      }
    });
  });

}).call(this);
