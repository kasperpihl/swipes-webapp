/*
 Brug evt:
 http://stackoverflow.com/questions/15912222/how-do-i-save-just-a-subset-of-a-backbone-models-attributes-to-the-server-witho
*/


(function() {
  define(["momentjs"], function() {
    return Parse.Object.extend({
      className: "ToDo",
      attrWhitelist: ["title", "order", "schedule", "completionDate", "repeatOption", "repeatDate", "repeatCount", "tags", "notes", "location", "priority", "deleted"],
      defaults: {
        title: "",
        order: void 0,
        schedule: "default",
        completionDate: null,
        repeatOption: "never",
        repeatDate: null,
        repeatCount: 0,
        tags: null,
        notes: "",
        location: void 0,
        priority: 0,
        deleted: false
      },
      initialize: function() {
        var saveOrder,
          _this = this;
        if (this.get("schedule") === "default") {
          this.set("schedule", this.getDefaultSchedule());
        }
        this.reviveDate("schedule");
        this.reviveDate("completionDate");
        this.reviveDate("repeatDate");
        if (this.get("repeatOption") !== "never") {
          this.updateRepeatDate();
        }
        this.setScheduleStr();
        this.setTimeStr();
        this.on("change:tags", function(me, tags) {
          if (tags.length) {
            return _this.syncTags(tags);
          }
        });
        this.on("change:schedule", function() {
          _this.setScheduleStr();
          _this.setTimeStr();
          _this.set("selected", false);
          _this.reviveDate("schedule");
          return _this.checkIfWeShouldListenForOrderChange();
        });
        this.on("change:completionDate", function() {
          _this.setCompletionStr();
          _this.setCompletionTimeStr();
          _this.set("selected", false);
          _this.reviveDate("completionDate");
          return _this.checkIfWeShouldListenForOrderChange();
        });
        this.on("change:repeatDate", function() {
          return _this.reviveDate("repeatDate");
        });
        this.on("change:repeatOption", this.setRepeatOption);
        this.on("destroy", this.cleanUp);
        if (this.has("completionDate")) {
          this.setCompletionStr();
          this.setCompletionTimeStr();
        }
        saveOrder = function() {
          return _this.save();
        };
        this.debouncedSaveOrder = _.debounce(saveOrder, 3000);
        return this.checkIfWeShouldListenForOrderChange(false);
      },
      checkIfWeShouldListenForOrderChange: function(removeEventListeners) {
        if (this.getState() === "active") {
          if (this.get("title")) {
            if (!this.get("deleted")) {
              return this.listenForOrderChanges();
            }
          }
        } else {
          if (removeEventListeners) {
            return this.stopListeningForOrderChanges();
          }
        }
      },
      listenForOrderChanges: function() {
        return this.on("change:order", this.debouncedSaveOrder);
      },
      stopListeningForOrderChanges: function() {
        return this.off("change:order", this.debouncedSaveOrder);
      },
      reviveDate: function(prop) {
        if (typeof this.get(prop) === "string") {
          return this.set(prop, new Date(this.get(prop)), {
            silent: true
          });
        }
      },
      getState: function() {
        var schedule;
        schedule = this.getValidatedSchedule();
        if (this.get("completionDate")) {
          return "completed";
        } else {
          if (schedule && schedule.getTime() <= new Date().getTime()) {
            return "active";
          } else {
            return "scheduled";
          }
        }
      },
      getDefaultSchedule: function() {
        var now;
        now = new Date();
        now.setSeconds(now.getSeconds() - 1);
        return now;
      },
      getValidatedSchedule: function() {
        var schedule;
        schedule = this.get("schedule");
        if (typeof schedule === "string") {
          this.set("schedule", new Date(schedule));
        }
        return this.get("schedule");
      },
      getTagStrList: function() {
        if (this.has("tags")) {
          return _.invoke(this.get("tags"), "get", "title");
        } else {
          return [];
        }
      },
      getDayWithoutTime: function(day) {
        var fullStr, timeIndex;
        fullStr = day.calendar();
        timeIndex = fullStr.indexOf(" at ");
        if (timeIndex !== -1) {
          return fullStr.slice(0, timeIndex);
        } else {
          return fullStr;
        }
      },
      syncTags: function(tags) {
        var actualTags, pointers, tag, _i, _len;
        pointers = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = tags.length; _i < _len; _i++) {
            tag = tags[_i];
            if (!tag.has("title")) {
              _results.push(tag.id);
            }
          }
          return _results;
        })();
        if (pointers.length) {
          tags = _.reject(tags, function(t) {
            return _.contains(pointers, t.id);
          });
          actualTags = this.getTagsFromPointers(pointers);
          for (_i = 0, _len = actualTags.length; _i < _len; _i++) {
            tag = actualTags[_i];
            tags.push(tag);
          }
          return this.set("tags", tags, {
            silent: true
          });
        }
      },
      getTagsFromPointers: function(pointers) {
        var result, tag, tagid, _i, _len;
        result = [];
        for (_i = 0, _len = pointers.length; _i < _len; _i++) {
          tagid = pointers[_i];
          tag = _.findWhere(swipy.tags.models, {
            id: tagid
          });
          if (tag) {
            result.push(tag);
          }
        }
        return result;
      },
      setScheduleStr: function() {
        var dayDiff, dayWithoutTime, now, parsedDate, result, schedule;
        schedule = this.get("schedule");
        if (!schedule) {
          return this.set("scheduleStr", "unspecified");
        }
        now = moment();
        parsedDate = moment(schedule);
        dayDiff = Math.abs(parsedDate.diff(now, "days"));
        if (dayDiff >= 6) {
          if (parsedDate.year() > now.year()) {
            result = parsedDate.format("MMM Do 'YY");
          } else {
            result = parsedDate.format("MMM Do");
          }
          return this.set("scheduleStr", result);
        }
        dayWithoutTime = this.getDayWithoutTime(parsedDate);
        if (dayWithoutTime === "Today" && !parsedDate.isBefore()) {
          dayWithoutTime = "Later today";
        }
        return this.set("scheduleStr", dayWithoutTime);
      },
      setTimeStr: function() {
        var schedule;
        schedule = this.get("schedule");
        if (!schedule) {
          return this.set("timeStr", void 0);
        }
        return this.set("timeStr", moment(schedule).format("h:mmA"));
      },
      setCompletionStr: function() {
        var completionDate, dayWithoutTime, now, parsedDate, result;
        completionDate = this.get("completionDate");
        if (!completionDate) {
          return this.unset("completionStr");
        }
        now = moment();
        parsedDate = moment(completionDate);
        if (parsedDate.diff(now, "days") <= -6) {
          if (parsedDate.year() < now.year()) {
            result = parsedDate.format("MMM Do 'YY");
          } else {
            result = parsedDate.format("MMM Do");
          }
          return this.set("completionStr", result);
        }
        dayWithoutTime = this.getDayWithoutTime(parsedDate);
        if (dayWithoutTime === "Today") {
          dayWithoutTime = "Earlier today";
        }
        return this.set("completionStr", dayWithoutTime);
      },
      setCompletionTimeStr: function() {
        var completionDate;
        completionDate = this.get("completionDate");
        if (!completionDate) {
          return this.unset("completionTimeStr");
        }
        return this.set("completionTimeStr", moment(completionDate).format("h:mmA"));
      },
      setRepeatOption: function(model, option) {
        if (this.get("schedule") && option !== "never") {
          return this.set("repeatDate", this.getNextDate(option));
        } else {
          return this.set("repeatDate", null);
        }
      },
      updateRepeatDate: function() {
        var option;
        option = this.get("repeatOption");
        if (this.get("schedule") && option !== "never") {
          return this.set("repeatDate", this.getNextDate(option));
        } else {
          return this.set("repeatDate", null);
        }
      },
      isWeekend: function(schedule) {
        if (schedule.getDay() === 0 || schedule.getDay() === 6) {
          return true;
        } else {
          return false;
        }
      },
      isWeekday: function(schedule) {
        return !this.isWeekend(schedule);
      },
      getMonFriSatSunFromDate: function(schedule, completionDate) {
        if (this.isWeekday(schedule)) {
          return this.getNextWeekDay(completionDate);
        } else {
          return this.getNextWeekendDay(completionDate);
        }
      },
      getNextWeekDay: function(date) {
        return date.add("days", date.day() === 5 ? 3 : 1).toDate();
      },
      getNextWeekendDay: function(date) {
        return date.add("days", date.day() === 0 ? 6 : 1).toDate();
      },
      getNextDate: function(option) {
        var completionDate, date, diff, repeatDate, type;
        if (this.has("completionDate")) {
          repeatDate = this.get("repeatDate");
          completionDate = this.get("completionDate");
          if (repeatDate) {
            if (repeatDate.getTime() > completionDate.getTime()) {
              return repeatDate;
            } else {
              switch (option) {
                case "every week":
                case "every month":
                case "every year":
                  date = moment(this.get("schedule"));
                  break;
                default:
                  date = moment(completionDate);
              }
            }
          } else {
            date = moment(completionDate);
          }
        } else {
          date = moment(this.get("schedule"));
          repeatDate = this.get("repeatDate");
          if (repeatDate && repeatDate.getTime() > this.get("schedule").getTime()) {
            date = moment(repeatDate);
          }
        }
        switch (option) {
          case "every day":
            return date.add("days", 1).toDate();
          case "every week":
          case "every month":
          case "every year":
            type = option.replace("every ", "") + "s";
            if (this.has("completionDate")) {
              diff = moment(this.get("completionDate")).diff(date, type, true);
            } else {
              diff = 1;
            }
            return date.add(type, Math.ceil(diff)).toDate();
          case "mon-fri or sat+sun":
            return this.getMonFriSatSunFromDate(this.get("schedule"), date);
          default:
            return null;
        }
      },
      sanitizeDataForDuplication: function(data) {
        var sanitizedData;
        sanitizedData = _.clone(data);
        sanitizedData = _.pick(sanitizedData, this.attrWhitelist);
        sanitizedData.repeatCount = 0;
        sanitizedData.repeatOption = "never";
        sanitizedData.repeatDate = null;
        return sanitizedData;
      },
      getScheduleBasedOnRepeatDate: function(repeatDate) {
        return repeatDate;
      },
      getRepeatableDuplicate: function() {
        if (this.has("repeatDate")) {
          return new this.constructor(this.sanitizeDataForDuplication(this.toJSON()));
        } else {
          throw new Error("You're trying to repeat a task that doesn't have a repeat date");
        }
      },
      toJSON: function() {
        this.set("state", this.getState());
        return _.clone(this.attributes);
      },
      /*
      		toJSON: ->
      			console.log "toJSON called!!!", _.pick( @attributes, @attrWhitelist )
      			_.pick( @attributes, @attrWhitelist )
      */

      cleanUp: function() {
        return this.off();
      }
    });
  });

}).call(this);
