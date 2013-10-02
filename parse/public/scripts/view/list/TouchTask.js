(function() {
  define(["view/list/BaseTask", 'hammer'], function(BaseTaskView, Hammer) {
    return BaseTaskView.extend({
      enableInteraction: function() {
        this.hammer = Hammer(this.content[0]).on("drag", this.handleDrag);
        return this.hammer = Hammer(this.content[0]).on("dragend", this.handleDragEnd);
      },
      disableInteraction: function() {
        return console.warn("Disabling touch gestures for ", this.model.toJSON());
      },
      getUserIntent: function(val) {
        var absDragAmount, dragAmount, name;
        dragAmount = val / window.innerWidth;
        absDragAmount = Math.abs(dragAmount);
        name = dragAmount > 0 ? "completed" : "scheduled";
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
          case "completed":
            this.$el.css("background", "hsla(144, 40%, 47%, " + (this.intent.amount * 4) + ")");
            break;
          case "scheduled":
            this.$el.css("background", "hsla(43, 78%, 44%, " + (this.intent.amount * 4) + ")");
            break;
        }
        return this.content.css("-webkit-transform", "translate3d(" + val + "px, 0, 0)");
      },
      handleDragEnd: function(e) {
        var delay,
          _this = this;
        if (this.intent.amount < 0.2) {
          return this.content.css({
            "-webkit-transform": "translate3d(0, 0, 0)",
            "background": ""
          });
        } else {
          delay = (1 - this.intent.amount) / 2;
          this.content.css({
            "-webkit-transition": "all " + delay + "s ease-out",
            "-webkit-transform": ""
          });
          this.$el.addClass(this.intent.name);
          return setTimeout(function() {
            return _this.$el.slideUp(200, function() {
              _this.model.set("state", _this.intent.name);
              return _this.model.save();
            });
          }, delay * 1000);
        }
      }
    });
  });

}).call(this);
