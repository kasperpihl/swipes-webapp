/*
 Brug evt:
 http://stackoverflow.com/questions/15912222/how-do-i-save-just-a-subset-of-a-backbone-models-attributes-to-the-server-witho
*/


(function() {
  define(["js/model/BaseModel", "js/utility/TimeUtility", "momentjs"], function(BaseModel, TimeUtility) {
    return BaseModel.extend({
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
      set: function() {
        BaseModel.prototype.handleForSync.apply(this, arguments);
        return Backbone.Model.prototype.set.apply(this, arguments);
      },
      constructor: function(attributes) {
        var hasTagsFromServer, model, modelTags, tag, _i, _len, _ref;
        if (attributes.tags && attributes.tags.length > 0) {
          modelTags = [];
          hasTagsFromServer = null;
          _ref = attributes.tags;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            tag = _ref[_i];
            if (!tag.objectId) {
              continue;
            }
            hasTagsFromServer = true;
            model = swipy.tags.get(tag.objectId);
            if (model) {
              modelTags.push(model);
            }
          }
          if (hasTagsFromServer) {
            attributes.tags = modelTags;
          }
        }
        return Backbone.Model.apply(this, arguments);
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
        this.setScheduleStr();
        this.setTimeStr();
        this.on("change:tags", function(me, tags) {
          if (!tags) {
            _this.set("tags", []);
          }
          return _this.syncTags(tags);
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
        var value;
        if (typeof this.get(prop) === "string") {
          this.set(prop, new Date(this.get(prop)), {
            silent: true
          });
        }
        if (_.isObject(this.get(prop)) && this.get(prop).__type === "Date") {
          value = new Date(this.get(prop).iso);
          return this.set(prop, value, {
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
        tags = _.compact(tags);
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
        if (pointers && pointers.length) {
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
      sanitizeDataForDuplication: function(data) {
        var sanitizedData;
        sanitizedData = _.clone(data);
        sanitizedData = _.pick(sanitizedData, this.attrWhitelist);
        sanitizedData.repeatCount = 0;
        sanitizedData.repeatOption = "never";
        sanitizedData.repeatDate = null;
        return sanitizedData;
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
      },
      togglePriority: function() {
        if (this.get("priority")) {
          return this.set("priority", 0, {
            sync: true
          });
        } else {
          return this.set("priority", 1, {
            sync: true
          });
        }
      },
      scheduleTask: function(date) {
        return this.set({
          schedule: date,
          completionDate: null
        }, {
          sync: true
        });
      },
      completeRepeatedTask: function() {
        var duplicate, nextDate, timeUtil;
        timeUtil = new TimeUtility();
        nextDate = timeUtil.getNextDateFrom(this.get("repeatDate"), this.get("repeatOption"));
        console.log(nextDate);
        if (!nextDate) {
          return;
        }
        duplicate = this.getRepeatableDuplicate();
        if (!duplicate) {
          return false;
        }
        duplicate.completeTask();
        swipy.todos.add(duplicate);
        return this.set({
          schedule: nextDate,
          repeatCount: this.get("repeatCount") + 1,
          repeatDate: nextDate
        }, {
          sync: true
        });
      },
      completeTask: function() {
        if (this.has("repeatDate")) {
          return this.completeRepeatedTask();
        }
        return this.set("completionDate", new Date(), {
          sync: true
        });
      },
      setRepeatOption: function(repeatOption) {
        var repeatDate;
        console.log(repeatOption);
        repeatDate = null;
        if (this.get("schedule") && repeatOption !== "never") {
          repeatDate = this.get("schedule");
        }
        return this.set({
          repeatDate: repeatDate,
          repeatOption: repeatOption
        }, {
          sync: true
        });
      },
      updateTags: function(tags) {
        return this.set("tags", tags, {
          sync: true
        });
      },
      updateTitle: function(title) {
        return this.set("title", title, {
          sync: true
        });
      },
      updateNotes: function(notes) {
        return this.set("notes", notes, {
          sync: true
        });
      },
      deleteTask: function() {
        return this.set("deleted", true, {
          sync: true
        });
      }
    });
  });

}).call(this);
