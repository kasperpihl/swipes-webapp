(function() {
  define(["underscore", "momentjs"], function(_, Moment) {
    var ScheduleModel;
    return ScheduleModel = (function() {
      function ScheduleModel(settings) {
        this.settings = settings;
        this.validateSettings();
        this.data = this.getData();
      }

      ScheduleModel.prototype.validateSettings = function() {};

      ScheduleModel.prototype.getData = function() {
        return [
          {
            id: "later today",
            title: this.getDynamicTime("Later Today"),
            disabled: false
          }, {
            id: "this evening",
            title: this.getDynamicTime("This Evening"),
            disabled: false
          }, {
            id: "tomorrow",
            title: this.getDynamicTime("Tomorrow"),
            disabled: false
          }, {
            id: "day after tomorrow",
            title: this.getDynamicTime("Day After Tomorrow"),
            disabled: false
          }, {
            id: "this weekend",
            title: this.getDynamicTime("This Weekend"),
            disabled: false
          }, {
            id: "next week",
            title: this.getDynamicTime("Next Week"),
            disabled: false
          }, {
            id: "unspecified",
            title: this.getDynamicTime("Unspecified"),
            disabled: false
          }, {
            id: "at location",
            title: this.getDynamicTime("At Location"),
            disabled: true
          }, {
            id: "pick a date",
            title: this.getDynamicTime("Pick A Date"),
            disabled: false
          }
        ];
      };

      ScheduleModel.prototype.getDateFromScheduleOption = function(option) {
        return new Date();
      };

      ScheduleModel.prototype.getDynamicTime = function(time) {
        switch (time) {
          case "This Evening":
            return "*DYNAMIC*";
          case "Day After Tomorrow":
            return "*DYNAMIC*";
          default:
            return time;
        }
      };

      ScheduleModel.prototype.toJSON = function() {
        return {
          options: this.data
        };
      };

      return ScheduleModel;

    })();
  });

}).call(this);
