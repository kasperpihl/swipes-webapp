(function() {
  define(['hammer'], function(Hammer) {
    return Backbone.View.extend({
      initialize: function() {
        _.bindAll(this);
        return this.render();
      },
      enableGestures: function() {
        log("Enabling gestures for ", this.model.toJSON());
        this.hammer = Hammer(this.el).on("drag", this.handleDrag);
        return this.hammer = Hammer(this.el).on("dragend", this.handleDragEnd);
      },
      disableGestures: function() {
        return log("Disabling gestures for ", this.model.toJSON());
      },
      handleDrag: function(e) {
        var val;
        val = e.gesture.direction === "left" ? e.gesture.distance * -1 : e.gesture.distance;
        if (val > window.innerWidth * 0.8) {
          val = window.innerWidth * 0.8;
        } else if (val < 0 - window.innerWidth * 0.8) {
          val = 0 - window.innerWidth * 0.8;
        }
        return this.$el.css("-webkit-transform", "translate3d(" + val + "px, 0, 0)");
      },
      handleDragEnd: function(e) {
        return this.$el.css("-webkit-transform", "translate3d(0, 0, 0)");
      },
      render: function() {
        this.enableGestures();
        return this.el;
      },
      remove: function() {
        return this.destroy();
      },
      destroy: function() {
        return this.disableGestures();
      }
    });
  });

}).call(this);
