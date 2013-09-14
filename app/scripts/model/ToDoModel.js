(function() {
  define(["backbone", "momentjs"], function(Backbone, Moment) {
    return Backbone.Model.extend({
      defaults: {
        title: "",
        order: 0,
        schedule: new Date(),
        completionDate: null,
        repeatOption: "never",
        repeatDate: null,
        repeatCount: 0,
        tags: null,
        notes: "",
        deleted: false
      },
      initialize: function() {
        this.setScheduleString();
        return this.on("change:schedule", this.setScheduleString);
      },
      setScheduleString: function() {
        var calendarWithoutTime, dayDiff, now, parsedDate, result, schedule;
        schedule = this.get("schedule");
        if (!schedule) {
          return this.set("scheduleString", void 0);
        }
        now = moment();
        parsedDate = moment(schedule);
        if (parsedDate.isBefore()) {
          return this.set("scheduleString", "past");
        }
        dayDiff = parsedDate.diff(now, "days");
        if (dayDiff > 7) {
          if (parsedDate.year() > now.year()) {
            result = parsedDate.format("MMM Do 'YY");
          } else {
            result = parsedDate.format("MMM Do");
          }
          return this.set("scheduleString", result);
        }
        calendarWithoutTime = parsedDate.calendar().match(/\w+/)[0];
        if (calendarWithoutTime === "Today") {
          calendarWithoutTime = "Later today";
        }
        return this.set("scheduleString", calendarWithoutTime);
      }
    });
  });

}).call(this);
