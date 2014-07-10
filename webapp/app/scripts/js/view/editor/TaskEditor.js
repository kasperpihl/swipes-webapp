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
        "blur .notes textarea": "updateNotes",
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
        this.$el.html(this.template(this.model.toJSON()));
        this.renderSubtasks();
        this.setStateClass();
        this.killTagEditor();
        this.createTagEditor();
        return this.el;
      },
      renderSubtasks: function() {
        var jsonedSubtasks, jsonedTask, task, tmplData, _i, _len, _ref;
        this.subtasks = this.sorter.setTodoOrder(this.model.getOrderedSubtasks(), false);
        tmplData = {};
        jsonedSubtasks = [];
        _ref = this.subtasks;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          task = _ref[_i];
          console.log(task.get("order"));
          jsonedTask = task.toJSON();
          jsonedTask.cid = task.cid;
          jsonedSubtasks.push(jsonedTask);
        }
        tmplData.subtasks = jsonedSubtasks;
        return $(this.el).find("#current-steps-container").html(_.template(ActionStepsTmpl)(tmplData));
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
        return this.model.updateNotes(this.getNotes());
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
          this.model.addNewSubtask(title);
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
        console.log(model);
        action = "complete";
        if (target.hasClass("todo")) {
          action = "todo";
        }
        if (action === "complete") {
          model.completeTask();
        } else {
          model.scheduleTask(null);
        }
        return this.renderSubtasks();
      },
      getTitle: function() {
        return this.$el.find(".title input").val();
      },
      getNotes: function() {
        return this.$el.find(".notes textarea").val();
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
