(function() {
  define(["underscore", "backbone", "text!templates/calendar.html", "momentjs", "clndr"], function(_, Backbone, CalendarTmpl) {
    return Backbone.View.extend({
      tagName: "div",
      className: "calendar-wrap",
      initialize: function() {
        _.bindAll(this, "afterRender", "handleClickDay", "handleMonthChanged", "handleYearChanged");
        this.today = moment();
        this.setTemplate();
        return this.render();
      },
      setTemplate: function() {
        return this.template = _.template(CalendarTmpl);
      },
      getCalendarOpts: function() {
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
        var el;
        this.days.removeClass("selected");
        el = element || this.getElementFromMoment(moment);
        return $(el).addClass("selected");
      },
      handleClickDay: function(day) {
        return this.selectDay(day.date, day.element);
      },
      handleYearChanged: function(moment) {
        return console.log("Switched year to ", moment.year());
      },
      handleMonthChanged: function(moment) {
        return console.log("Switched month to ", moment.month());
      },
      render: function() {
        this.createCalendar();
        return this;
      },
      afterRender: function() {
        this.days = this.$el.find(".day");
        return this.selectDay(this.today);
      }
    });
  });

}).call(this);
