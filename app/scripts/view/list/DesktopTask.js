(function() {
  define(["underscore", "view/list/BaseTask"], function(_, BaseTaskView) {
    return BaseTaskView.extend({
      events: {
        "mouseenter": "trackMouse",
        "mouseleave": "stopTrackingMouse"
      },
      init: function() {
        this.throttledOnMouseMove = _.throttle(this.onMouseMove, 250);
        _.bindAll(this, "setBounds", "onMouseMove", "throttledOnMouseMove", "onHoverComplete", "onHoverSchedule", "onUnhoverComplete", "onUnhoverSchedule");
        this.listenTo(Backbone, "hover-complete", this.onHoverComplete);
        this.listenTo(Backbone, "hover-schedule", this.onHoverSchedule);
        this.listenTo(Backbone, "unhover-complete", this.onUnhoverComplete);
        return this.listenTo(Backbone, "unhover-schedule", this.onUnhoverSchedule);
      },
      getMousePos: function(mouseX) {
        if (!this.bounds) {
          this.setBounds();
        }
        return Math.round(((mouseX - this.bounds.left) / this.bounds.width) * 100);
      },
      trackMouse: function() {
        this.allowThrottledMoveHandler = true;
        return this.$el.on("mousemove", this.throttledOnMouseMove);
      },
      stopTrackingMouse: function() {
        this.$el.off("mousemove");
        this.isHoveringComplete = this.isHoveringSchedule = false;
        this.allowThrottledMoveHandler = false;
        Backbone.trigger("unhover-complete", this.cid);
        return Backbone.trigger("unhover-schedule", this.cid);
      },
      onMouseMove: function(e) {
        if (!this.allowThrottledMoveHandler) {
          return;
        }
        return this.determineUserIntent(this.getMousePos(e.pageX));
      },
      determineUserIntent: function(mousePos) {
        if (mousePos <= 15 && !this.isHoveringComplete) {
          Backbone.trigger("hover-complete", this.cid);
          this.isHoveringComplete = true;
        } else if (mousePos > 15 && this.isHoveringComplete) {
          Backbone.trigger("unhover-complete", this.cid);
          this.isHoveringComplete = false;
        }
        if (mousePos >= 85 && !this.isHoveringSchedule) {
          Backbone.trigger("hover-schedule", this.cid);
          return this.isHoveringSchedule = true;
        } else if (mousePos < 85 && this.isHoveringSchedule) {
          Backbone.trigger("unhover-schedule", this.cid);
          return this.isHoveringSchedule = false;
        }
      },
      onHoverComplete: function(target) {
        if (this.model.get("selected") || target === this.cid) {
          return this.$el.addClass("hover-complete");
        }
      },
      onHoverSchedule: function(target) {
        if (this.model.get("selected") || target === this.cid) {
          return this.$el.addClass("hover-schedule");
        }
      },
      onUnhoverComplete: function(target) {
        if (this.model.get("selected") || target === this.cid) {
          return this.$el.removeClass("hover-complete");
        }
      },
      onUnhoverSchedule: function(target) {
        if (this.model.get("selected") || target === this.cid) {
          return this.$el.removeClass("hover-schedule");
        }
      },
      customCleanUp: function() {
        return this.stopTrackingMouse();
      }
    });
  });

}).call(this);
