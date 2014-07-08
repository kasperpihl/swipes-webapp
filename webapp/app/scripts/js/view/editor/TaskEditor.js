(function() {
  define(["underscore", "backbone", "text!templates/task-editor.html", "js/view/editor/TagEditor"], function(_, Backbone, TaskEditorTmpl, TagEditor) {
    return Backbone.View.extend({
      tagName: "article",
      className: "task-editor",
      events: {
        "click .save": "save",
        "click .priority": "togglePriority",
        "click time": "reschedule",
        "click .repeat-picker a": "setRepeat",
        "blur .title input": "updateTitle",
        "blur .notes textarea": "updateNotes"
      },
      initialize: function() {
        $("body").addClass("edit-mode");
        this.setTemplate();
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
        var jsonedSubtasks, jsonedTask, subtasks, task, taskJSON, _i, _len;
        subtasks = this.model.getOrderedSubtasks();
        jsonedSubtasks = [];
        for (_i = 0, _len = subtasks.length; _i < _len; _i++) {
          task = subtasks[_i];
          jsonedTask = task.toJSON();
          jsonedSubtasks.push(jsonedTask);
        }
        taskJSON = this.model.toJSON();
        taskJSON.subtasks = jsonedSubtasks;
        this.$el.html(this.template(taskJSON));
        this.setStateClass();
        this.killTagEditor();
        this.createTagEditor();
        return this.el;
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
