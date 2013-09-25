(function() {
  define(["underscore", "backbone", "text!templates/edit-task.html"], function(_, Backbone, TaskTmpl) {
    return Backbone.View.extend({
      tagName: "article",
      className: "task-editor",
      events: {
        "click .cancel": "back",
        "click .save": "save"
      },
      initialize: function() {
        this.model.on("change", this.render, this);
        this.setTemplate();
        return this.render();
      },
      setTemplate: function() {
        return this.template = _.template(TaskTmpl);
      },
      render: function() {
        if (this.template == null) {
          return this.el;
        }
        this.$el.html(this.template(this.model.toJSON()));
        return this.el;
      },
      back: function() {
        return swipy.router.navigate("todo", true);
      },
      save: function() {
        this.saveTitle();
        this.saveSchedule();
        this.saveRepeat();
        this.saveTags();
        return this.saveNotes();
      },
      saveTitle: function() {
        return console.log("Saving title");
      },
      saveSchedule: function() {
        return console.log("Saving schedule");
      },
      saveRepeat: function() {
        return console.log("Saving repeat option");
      },
      saveTags: function() {
        return console.log("Saving tags");
      },
      saveNotes: function() {
        return console.log("Saving notes");
      },
      remove: function() {
        this.cleanUp();
        return this.$el.remove();
      },
      cleanUp: function() {
        this.model.off();
        return this.undelegateEvents();
      }
    });
  });

}).call(this);
