(function() {
  define(['hammer'], function(Hammer) {
    return Backbone.View.extend({
      initialize: function() {
        _.bindAll(this);
        this.content = this.$el.find('.todo-content');
        return this.render();
      },
      enableGestures: function() {
        this.hammer = Hammer(this.content[0]).on("drag", this.handleDrag);
        return this.hammer = Hammer(this.content[0]).on("dragend", this.handleDragEnd);
      },
      disableGestures: function() {
        return log("Disabling gestures for ", this.model.toJSON());
      },
      getUserIntent: function(val) {
        var absDragAmount, dragAmount, name;
        dragAmount = val / window.innerWidth;
        absDragAmount = Math.abs(dragAmount);
        name = dragAmount > 0 ? "done" : "prostpone";
        return {
          name: name,
          amount: absDragAmount
        };
      },
      handleDrag: function(e) {
        var val;
        val = e.gesture.direction === "left" ? e.gesture.distance * -1 : e.gesture.distance;
        this.intent = this.getUserIntent(val);
        switch (this.intent.name) {
          case "done":
            this.$el.css("background", "hsla(144, 40%, 47%, " + (this.intent.amount * 4) + ")");
            break;
          case "prostpone":
            this.$el.css("background", "hsla(43, 78%, 44%, " + (this.intent.amount * 4) + ")");
            break;
        }
        return this.content.css("-webkit-transform", "translate3d(" + val + "px, 0, 0)");
      },
      handleDragEnd: function(e) {
        if (this.intent.amount < 0.2) {
          this.content.css({
            "-webkit-transform": "translate3d(0, 0, 0)",
            "background": ""
          });
          return;
        }
        switch (this.intent.name) {
          case "done":
            this.$el.addClass("done");
            alert("done!");
            break;
          case "prostpone":
            this.$el.addClass("prostponed");
            alert("prostponed");
            break;
        }
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
