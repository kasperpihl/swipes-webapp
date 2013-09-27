(function() {
  define(["underscore", "backbone", "text!templates/task.html"], function(_, Backbone, TaskTmpl) {
    return Backbone.View.extend({
      tagName: "li",
      initialize: function() {
        _.bindAll(this, "onSelected", "setBounds", "toggleSelected", "edit");
        this.listenTo(this.model, "change:selected", this.onSelected);
        $(window).on("resize", this.setBounds);
        this.setTemplate();
        this.init();
        this.render();
        this.$el.on("click", ".todo-content", this.toggleSelected);
        return this.$el.on("dblclick", "h2", this.edit);
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
