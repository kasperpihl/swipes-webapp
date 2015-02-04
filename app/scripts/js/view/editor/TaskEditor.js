(function() {
  define(["underscore", "backbone", "text!templates/task-editor.html", "text!templates/action-steps-template.html", "js/model/TaskSortModel", "js/view/editor/TagEditor"], function(_, Backbone, TaskEditorTmpl, ActionStepsTmpl, TaskSortModel, TagEditor) {
    return Backbone.View.extend({
      tagName: "article",
      className: "task-editor",
      events: {
        "click .save": "save",
        "click .priority": "togglePriority",
        "click time": "reschedule",
        "click .repeat-picker a": "setRepeat",
        "blur .title input": "updateTitle",
        "blur .notes .input-note": "updateNotes",
        "change .step input": "updateActionStep",
        "click .step .action": "clickedAction"
      },
      initialize: function() {
        $("body").addClass("edit-mode");
        this.setTemplate();
        this.sorter = new TaskSortModel();
        _.bindAll(this, "clickedAction", 'updateActionStep');
        this.render();
        return this.listenTo(this.model, "change:schedule change:repeatOption change:priority change:title", this.render);
      },
      setTemplate: function() {
        return this.template = _.template(TaskEditorTmpl);
      },
      killTagEditor: function() {
        if (this.tagEditor != null) {
          this.tagEditor.cleanUp();
          return this.tagEditor.remove();
        }
      },
      createTagEditor: function() {
        return this.tagEditor = new TagEditor({
          el: this.$el.find(".icon-tag-bold"),
          model: this.model
        });
      },
      setStateClass: function() {
        return this.$el.removeClass("active scheduled completed").addClass(this.model.getState());
      },
      render: function() {
        var addExtraPoint, addedNewline, brStartIndex, counter, expression, foundURLs, index, input, m, nextText, regex, renderedContent, tempNoteString, url;
        renderedContent = this.model.toJSON();
        if (renderedContent.notes && renderedContent.notes.length > 0) {
          renderedContent.notes = renderedContent.notes.replace(/(?:\r\n|\r|\n)/g, '<br>');
          expression = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/g;
          regex = new RegExp(expression);
          tempNoteString = renderedContent.notes;
          foundURLs = [];
          counter = 0;
          while (m = regex.exec(tempNoteString)) {
            counter++;
            index = m.index;
            url = m[0];
            input = m.input;
            brStartIndex = index + url.length;
            nextText = input.substring(brStartIndex);
            addedNewline = false;
            if ((nextText != null) && nextText.length > 3) {
              if (nextText.indexOf("<br>") === 0) {
                url += "<br>";
                addedNewline = true;
                tempNoteString = tempNoteString.slice(0, brStartIndex) + tempNoteString.substr(brStartIndex + 4);
              }
            }
            if ((nextText == null) || nextText.length < 5) {
              addExtraPoint = false;
              if (nextText.length === 0) {
                addExtraPoint = true;
              }
              if (addedNewline) {
                addExtraPoint = true;
              }
              if (addExtraPoint) {
                renderedContent.notes += "<div><br></div>";
              }
            }
            if (foundURLs.indexOf(url) === -1) {
              renderedContent.notes = renderedContent.notes.replace(url, "<div contentEditable><a href=\"" + url + "\" target=\"_blank\" contentEditable=\"false\">" + url + "</a></div>");
              foundURLs.push(url);
            }
          }
        }
        this.$el.html(this.template(renderedContent));
        this.renderSubtasks();
        this.setStateClass();
        this.killTagEditor();
        this.createTagEditor();
        return this.el;
      },
      renderSubtasks: function() {
        var completedCounter, jsonedSubtasks, jsonedTask, task, titleString, tmplData, _i, _len, _ref;
        this.subtasks = this.sorter.setTodoOrder(this.model.getOrderedSubtasks(), false);
        titleString = "Tasks";
        if (this.subtasks.length > 0) {
          tmplData = {};
          jsonedSubtasks = [];
          completedCounter = 0;
          _ref = this.subtasks;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            task = _ref[_i];
            if (task.get("completionDate")) {
              completedCounter++;
            }
            jsonedTask = task.toJSON();
            jsonedTask.cid = task.cid;
            jsonedSubtasks.push(jsonedTask);
          }
          tmplData.subtasks = jsonedSubtasks;
          titleString = "" + completedCounter + " / " + jsonedSubtasks.length + " Steps";
          $(this.el).find("#current-steps-container").html(_.template(ActionStepsTmpl)(tmplData));
        }
        return $(this.el).find(".divider h2").html(titleString);
      },
      save: function() {
        return swipy.router.back();
      },
      reschedule: function() {
        return Backbone.trigger("show-scheduler", [this.model]);
      },
      transitionInComplete: function() {},
      togglePriority: function() {
        return this.model.togglePriority();
      },
      setRepeat: function(e) {
        return this.model.setRepeatOption($(e.currentTarget).data("option"));
      },
      updateTitle: function() {
        return this.model.updateTitle(this.getTitle());
      },
      updateNotes: function() {
        if (this.getNotes() !== this.model.get("notes")) {
          this.model.updateNotes(this.getNotes());
          swipy.analytics.sendEvent("Tasks", "Notes", "", this.getNotes().length);
          swipy.analytics.sendEventToIntercom("Update Note", {
            "Length": this.getNotes().length
          });
          return this.render();
        }
      },
      updateActionStep: function(e) {
        var model, target, title;
        target = $(e.currentTarget);
        title = target.val();
        title = title.trim();
        model = this.getModelFromEl($(e.currentTarget));
        if (title.length === 0) {
          if (model != null) {
            target.val(model.get("title"));
          }
          return false;
        }
        if (title.length > 255) {
          title = title.substr(0, 255);
        }
        if (model != null) {
          model.updateTitle(title);
        } else {
          this.model.addNewSubtask(title, "Input");
          target.val("");
        }
        return this.renderSubtasks();
      },
      getModelFromEl: function(el) {
        var cid, foundTask, step, task, _i, _len, _ref;
        step = el.closest(".step");
        cid = step.attr("data-cid");
        _ref = this.subtasks;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          task = _ref[_i];
          if (task.cid === cid) {
            foundTask = task;
          }
        }
        return foundTask;
      },
      clickedAction: function(e) {
        var action, model, target;
        target = $(e.currentTarget);
        model = this.getModelFromEl(target);
        action = "complete";
        if (target.hasClass("todo")) {
          action = "todo";
        }
        if (action === "complete") {
          model.completeTask();
          swipy.analytics.sendEvent("Action Steps", "Completed");
          swipy.analytics.sendEventToIntercom("Completed Action Step");
        } else {
          model.scheduleTask(null);
        }
        return this.renderSubtasks();
      },
      getTitle: function() {
        return this.$el.find(".title input").val();
      },
      getNotes: function() {
        var $noteField, replacedBrs;
        $noteField = this.$el.find('.notes .input-note');
        replacedBrs = $noteField.html().replace(/<br>/g, "\r\n");
        replacedBrs = replacedBrs.replace(/<(?:.|\n)*?>/gm, '');
        return replacedBrs;
      },
      remove: function() {
        $("body").removeClass("edit-mode");
        this.undelegateEvents();
        this.stopListening();
        return this.$el.remove();
      }
    });
  });

}).call(this);
