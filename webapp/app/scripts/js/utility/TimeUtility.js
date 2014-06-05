(function() {
  define(function() {
    var TimeUtility;
    return TimeUtility = (function() {
      function TimeUtility() {}

      TimeUtility.prototype.isWeekend = function(schedule) {
        if (schedule.getDay() === 0 || schedule.getDay() === 6) {
          return true;
        } else {
          return false;
        }
      };

      TimeUtility.prototype.isWeekday = function(schedule) {
        return !this.isWeekend(schedule);
      };

      TimeUtility.prototype.getMonFriSatSunFromDate = function(schedule) {
        if (this.isWeekday(schedule)) {
          return this.getNextWeekDay(schedule);
        } else {
          return this.getNextWeekendDay(schedule);
        }
      };

      TimeUtility.prototype.getNextWeekDay = function(date) {
        return date.add("days", date.day() === 5 ? 3 : 1).toDate();
      };

      TimeUtility.prototype.getNextWeekendDay = function(date) {
        return date.add("days", date.day() === 0 ? 6 : 1).toDate();
      };

      TimeUtility.prototype.getNextDateFrom = function(date, option) {
        var diff, nextDate, now, type;
        now = new Date().getTime();
        nextDate = date;
        while (true) {
          nextDate = moment(nextDate);
          switch (option) {
            case "every day":
              nextDate = nextDate.add("days", 1).toDate();
              break;
            case "every week":
            case "every month":
            case "every year":
              type = option.replace("every ", "") + "s";
              diff = 1;
              nextDate = nextDate.add(type, Math.ceil(diff)).toDate();
              break;
            case "mon-fri or sat+sun":
              nextDate = this.getMonFriSatSunFromDate(nextDate.toDate());
              break;
            default:
              return null;
          }
          if (nextDate.getTime() > now) {
            break;
          }
        }
        return nextDate;
      };

      return TimeUtility;

    })();
  });

}).call(this);
