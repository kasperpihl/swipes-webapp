(function() {
  define(["underscore", "backbone", "text!templates/task-editor.html", "text!templates/action-steps-template.html", "js/view/editor/TagEditor"], function(_, Backbone, TaskEditorTmpl, ActionStepsTmpl, TagEditor) {
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
        _.bindAll(this, "clickedAction");
        this.render();
        return this.listenTo(this.model, "change:schedule change:repeatOption change:priority", this.render);
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
        this.subtasks = this.model.getOrderedSubtasks();
        this.$el.html(this.template(this.model.toJSON()));
        this.renderSubtasks();
        this.setStateClass();
        this.killTagEditor();
        this.createTagEditor();
        return this.el;
      },
      renderSubtasks: function() {
        var jsonedSubtasks, jsonedTask, task, tmplData, _i, _len, _ref;
        tmplData = {};
        jsonedSubtasks = [];
        _ref = this.subtasks;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          task = _ref[_i];
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
        console.log(e);
        return console.log($(e.target));
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
