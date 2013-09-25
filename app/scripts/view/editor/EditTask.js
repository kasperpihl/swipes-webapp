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
        var atts, opts,
          _this = this;
        atts = {
          title: this.getTitle(),
          schedule: this.getSchedule(),
          repeatDate: this.getRepeatDate(),
          tags: this.getTags(),
          notes: this.getNotes()
        };
        opts = {
          success: function() {
            return _this.back();
          },
          error: function(e) {
            console.warn("Error saving ", arguments);
            return alert("Something went wrong. Please try again in a little bit.");
          }
        };
        return this.model.save(atts, opts);
      },
      getTitle: function() {
        return this.$el.find(".title")[0].innerText;
      },
      getSchedule: function() {
        return console.log("Saving schedule");
      },
      getRepeatDate: function() {
        return console.log("Saving repeat option");
      },
      getTags: function() {
        return console.log("Saving tags");
      },
      getNotes: function() {
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
