(function() {
  define(function() {
    return Backbone.View.extend({
      initialize: function() {
        _.bindAll(this);
        this.content = this.$el.find('.todo-content');
        return this.render();
      },
      enableInteraction: function() {},
      disableInteraction: function() {
        return console.warn("Disabling gestures for ", this.model.toJSON());
      },
      render: function() {
        this.enableInteraction();
        return this.el;
      },
      remove: function() {
        this.destroy();
        return this.model.off();
      },
      destroy: function() {
        return this.disableInteraction();
      }
    });
  });

}).call(this);
