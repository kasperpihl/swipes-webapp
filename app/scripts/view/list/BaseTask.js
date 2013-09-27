(function() {
  define(["underscore", "backbone", "text!templates/task.html"], function(_, Backbone, TaskTmpl) {
    return Backbone.View.extend({
      tagName: "li",
      initialize: function() {
        _.bindAll(this, "onSelected", "setBounds", "toggleSelected", "edit", "handleAction");
        this.listenTo(this.model, "change:selected", this.onSelected);
        $(window).on("resize", this.setBounds);
        this.setTemplate();
        this.init();
        this.render();
        this.$el.on("click", ".todo-content", this.toggleSelected);
        this.$el.on("dblclick", "h2", this.edit);
        return this.$el.on("click", ".action", this.handleAction);
      },
      setTemplate: function() {
        return this.template = _.template(TaskTmpl);
      },
      setBounds: function() {
        return this.bounds = this.el.getClientRects()[0];
      },
      init: function() {},
      toggleSelected: function() {
        var currentlySelected;
        currentlySelected = this.model.get("selected") || false;
        return this.model.set("selected", !currentlySelected);
      },
      handleAction: function(e) {
        var selectedTasks, task, trigger, _i, _len,
          _this = this;
        trigger = [this.model];
        selectedTasks = swipy.todos.where({
          selected: true
        });
        if (selectedTasks.length) {
          selectedTasks = _.reject(selectedTasks, function(m) {
            return m.cid === _this.model.cid;
          });
          for (_i = 0, _len = selectedTasks.length; _i < _len; _i++) {
            task = selectedTasks[_i];
            trigger.push(task);
          }
        }
        if ($(e.currentTarget).hasClass("schedule")) {
          return Backbone.trigger("schedule-task", trigger);
        } else if ($(e.currentTarget).hasClass("complete")) {
          return Backbone.trigger("complete-task", trigger);
        }
      },
      onSelected: function(model, selected) {
        return this.$el.toggleClass("selected", selected);
      },
      edit: function() {
        return swipy.router.navigate("edit/" + this.model.cid, true);
      },
      render: function() {
        if (this.template == null) {
          return this.el;
        }
        this.$el.html(this.template(this.model.toJSON()));
        return this.el;
      },
      remove: function() {
        this.cleanUp();
        return this.$el.remove();
      },
      customCleanUp: function() {},
      cleanUp: function() {
        $(window).off();
        this.$el.off();
        this.undelegateEvents();
        this.stopListening();
        return this.customCleanUp();
      }
    });
  });

}).call(this);
