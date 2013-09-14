(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      initialize: function() {
        _.bindAll(this, "handleSelected");
        this.init();
        this.content = this.$el.find('.todo-content');
        this.model.on("change:selected", this.handleSelected);
        return this.render();
      },
      init: function() {},
      handleSelected: function(model, selected) {
        return this.$el.toggleClass("selected", selected);
      },
      render: function() {
        return this.el;
      },
      remove: function() {
        return this.cleanUp();
      },
      cleanUp: function() {
        return this.model.off();
      }
    });
  });

}).call(this);
