(function() {
  define(["underscore", "view/list/BaseListItem"], function(_, BaseListItemView) {
    return BaseListItemView.extend({
      events: {
        "click": "toggleSelected",
        "mouseenter": "trackMouse",
        "mouseleave": "stopTrackingMouse"
      },
      init: function() {
        this.throttledOnMouseMove = _.throttle(this.onMouseMove, 250);
        _.bindAll(this, "setBounds", "onMouseMove", "throttledOnMouseMove", "onHoverComplete", "onHoverSchedule", "onUnhoverComplete", "onUnhoverSchedule");
        $(window).on("resize", this.setBounds);
        Backbone.on("hover-complete", this.onHoverComplete);
        Backbone.on("hover-schedule", this.onHoverSchedule);
        Backbone.on("unhover-complete", this.onUnhoverComplete);
        return Backbone.on("unhover-schedule", this.onUnhoverSchedule);
      },
      toggleSelected: function() {
        var currentlySelected;
        currentlySelected = this.model.get("selected") || false;
        return this.model.set("selected", !currentlySelected);
      },
      setBounds: function() {
        return this.bounds = this.el.getClientRects()[0];
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
        if (swipy.todos.any(function(model) {
          return model.get("selected");
        })) {
          if (!this.model.get("selected")) {
            return false;
          }
        }
        return this.determineUserIntent(this.getMousePos(e.pageX));
      },
      determineUserIntent: function(mousePos) {
        if (mousePos <= 15 && this.isHoveringComplete !== true) {
          Backbone.trigger("hover-complete", this.cid);
          this.isHoveringComplete = true;
        } else if (mousePos > 15 && this.isHoveringComplete) {
          Backbone.trigger("unhover-complete", this.cid);
          this.isHoveringComplete = false;
        }
        if (mousePos >= 85 && this.isHoveringSchedule !== true) {
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
        $(window).off();
        return this.stopTrackingMouse();
      }
    });
  });

}).call(this);
