(function() {
  define(["underscore", "backbone", "text!templates/task.html"], function(_, Backbone, TaskTmpl) {
    return Backbone.View.extend({
      tagName: "li",
      initialize: function() {
        _.bindAll(this, "onSelected");
        this.model.on("change:selected", this.onSelected);
        this.setTemplate();
        this.init();
        this.content = this.$el.find('.todo-content');
        return this.render();
      },
      setTemplate: function() {
        return this.template = _.template(TaskTmpl);
      },
      init: function() {},
      onSelected: function(model, selected) {
        return this.$el.toggleClass("selected", selected);
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
