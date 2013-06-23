(function() {
  define(['hammer'], function(Hammer) {
    return Backbone.View.extend({
      initialize: function() {
        _.bindAll(this);
        return this.render();
      },
      enableGestures: function() {
        log("Enabling gestures for ", this.model.toJSON());
        return this.hammer = Hammer(this.el).on("drag", this.handleDrag);
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
        return this.$el.css("left", "" + val + "px");
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
