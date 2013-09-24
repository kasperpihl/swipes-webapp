(function() {
  define(["underscore", "backbone", "text!templates/edit-task.html"], function(_, Backbone, TaskTmpl) {
    return Backbone.View.extend({
      tagName: "article",
      className: "task-editor",
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
      remove: function() {
        return this.cleanUp();
      },
      customCleanUp: function() {},
      cleanUp: function() {
        this.model.off();
        return this.customCleanUp();
      }
    });
  });

}).call(this);
