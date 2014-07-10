/*
 Brug evt:
 http://stackoverflow.com/questions/15912222/how-do-i-save-just-a-subset-of-a-backbone-models-attributes-to-the-server-witho
*/


(function() {
  define(["js/model/BaseModel", "js/utility/TimeUtility", "momentjs"], function(BaseModel, TimeUtility) {
    return BaseModel.extend({
      className: "ToDo",
      idAttribute: "objectId",
      subtasks: [],
      attrWhitelist: ["title", "order", "schedule", "completionDate", "repeatOption", "repeatDate", "repeatCount", "tags", "notes", "location", "parentLocalId", "priority", "origin", "originIdentifier"],
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
        parentLocalId: null,
        priority: 0,
        deleted: false,
        origin: null,
        originIdentifier: null
      },
      set: function() {
        BaseModel.prototype.handleForSync.apply(this, arguments);
        return Backbone.Model.prototype.set.apply(this, arguments);
      },
      constructor: function(attributes) {
        var parentModel;
        if (attributes.tags && attributes.tags.length > 0) {
          attributes.tags = this.handleTagsFromServer(attributes.tags);
        }
        BaseModel.apply(this, arguments);
        if (attributes.parentLocalId) {
          parentModel = swipy.todos.get(attributes.parentLocalId);
          if (parentModel) {
            this.set("parent", parentModel);
            return parentModel.addSubtask(this);
          }
        }
      },
      addSubtask: function(model) {
        return this.subtasks.push(model);
      },
      addNewSubtask: function(title) {
        var currentSubtasks, order, parentLocalId;
        currentSubtasks = this.getOrderedSubtasks();
        parentLocalId = this.get("tempId");
        if (this.id != null) {
          parentLocalId = this.id;
        }
        order = currentSubtasks.length;
        return swipy.todos.create({
          title: title,
          parentLocalId: parentLocalId,
          order: order
        });
      },
      initialize: function() {
        var _this = this;
        if (this.get("schedule") === "default") {
          this.scheduleTask(this.getDefaultSchedule());
        }
        this.reviveDate("schedule");
        this.reviveDate("completionDate");
        this.reviveDate("repeatDate");
        this.setScheduleStr();
        this.setTimeStr();
        this.on("change:tags", function(me, tags) {
          if (!tags) {
            _this.updateTags([]);
          }
          return _this.syncTags(tags);
        });
        this.on("change:schedule", function() {
          _this.setScheduleStr();
          _this.setTimeStr();
          _this.set("selected", false);
          return _this.reviveDate("schedule");
        });
        this.on("change:completionDate", function() {
          _this.setCompletionStr();
          _this.setCompletionTimeStr();
          _this.set("selected", false);
          return _this.reviveDate("completionDate");
        });
        this.on("change:repeatDate", function() {
          return _this.reviveDate("repeatDate");
        });
        this.on("destroy", this.cleanUp);
        if (this.has("completionDate")) {
          this.setCompletionStr();
          return this.setCompletionTimeStr();
        }
      },
      reviveDate: function(prop) {
        var value;
        value = this.handleDateFromServer(this.get(prop));
        return this.set(prop, value, {
          silent: true
        });
      },
      isSubtask: function() {
        if (this.get("parent")) {
          return true;
        } else {
          return false;
        }
      },
      getOrderedSubtasks: function() {
        return swipy.todos.getSubtasksForModel(this);
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
          this.scheduleTask(new Date(schedule));
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
        var updateObj;
        updateObj = {
          schedule: date,
          completionDate: null
        };
        if (!this.isSubtask()) {
          updateObj.order = -1;
        }
        this.unset("schedule");
        return this.set(updateObj, {
          sync: true
        });
      },
      completeRepeatedTask: function() {
        var duplicate, nextDate, timeUtil;
        timeUtil = new TimeUtility();
        nextDate = timeUtil.getNextDateFrom(this.get("repeatDate"), this.get("repeatOption"));
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
      updateOrder: function(order, opt) {
        var key, options, value;
        if (order === this.get("order")) {
          return;
        }
        options = {
          sync: true
        };
        for (key in opt) {
          value = opt[key];
          options[key] = value;
        }
        return this.set("order", order, options);
      },
      updateTags: function(tags) {
        this.unset("tags", {
          silent: true
        });
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
      updateFromServerObj: function(obj, recentChanges) {
        var attribute, dateKeys, val, _i, _len, _ref;
        BaseModel.prototype.updateFromServerObj.apply(this, arguments);
        dateKeys = ["schedule", "completionDate", "repeatDate"];
        _ref = this.attrWhitelist;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          attribute = _ref[_i];
          if (obj[attribute] == null) {
            continue;
          }
          if ((recentChanges != null) && _.indexOf(recentChanges, attribute !== -1)) {
            continue;
          }
          val = obj[attribute];
          if (attribute === "tags") {
            val = this.handleTagsFromServer(val);
          } else if (_.indexOf(dateKeys, attribute) !== -1) {
            val = this.handleDateFromServer(val);
          }
          if (val !== this.get(attribute)) {
            this.set(attribute, val);
          }
        }
        return false;
      },
      handleTagsFromServer: function(tags) {
        var model, modelTags, tag, _i, _len;
        modelTags = [];
        for (_i = 0, _len = tags.length; _i < _len; _i++) {
          tag = tags[_i];
          if (!tag.objectId) {
            continue;
          }
          model = swipy.tags.get(tag.objectId);
          if (model) {
            modelTags.push(model);
          }
        }
        return modelTags;
      },
      handleDateFromServer: function(date) {
        if (typeof date === "string") {
          date = new Date(date);
        } else if (_.isObject(date) && date.__type === "Date") {
          date = new Date(date.iso);
        }
        return date;
      }
    });
  });

}).call(this);
