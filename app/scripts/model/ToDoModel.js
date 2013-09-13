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
        var calndarWithoutTime, now, parsedDate, result, schedule;
        schedule = this.get("schedule");
        if (!schedule) {
          return this.set("scheduleString", void 0);
        }
        now = moment();
        parsedDate = moment(schedule);
        if (parsedDate.isBefore(now)) {
          return this.set("scheduleString", "past");
        }
        if (parsedDate.diff(now, "days") > 7) {
          if (parsedDate.year() > now.year()) {
            result = parsedDate.format("MMM Do 'YY");
          } else {
            result = parsedDate.format("MMM Do");
          }
          return this.set("scheduleString", result);
        }
        calndarWithoutTime = parsedDate.calendar().match(/\w+/)[0];
        return this.set("scheduleString", calndarWithoutTime);
      }
    });
  });

}).call(this);
