(function() {
  define(["view/list/BaseListItem"], function(BaseListItemView) {
    return BaseListItemView.extend({
      events: {
        "click": "toggleSelected",
        "mouseenter .todo-content": "onHover",
        "mouseleave .todo-content": "onHover"
      },
      init: function() {
        var _this = this;
        _.bindAll(this, "onHover", "onMouseMove", "onHoverComplete", "onHoverSchedule", "onUnhoverComplete", "onUnhoverSchedule");
        this.width = this.$el.width();
        this.x = this.$el.offset().left;
        $(window).on("resize", function() {
          _this.width = _this.$el.width();
          return _this.x = _this.$el.offset().left;
        });
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
      getMousePos: function(mouseX) {
        mouseX = mouseX - this.x;
        return Math.round((mouseX / this.width) * 100);
      },
      trackMouse: function() {
        return this.$el.on("mousemove", this.onMouseMove);
      },
      stopTrackingMouse: function() {
        this.$el.off("mousemove");
        return this.isHoveringComplete = this.isHoveringSchedule = false;
      },
      onHover: function(e) {
        if (e.type === "mouseenter") {
          return this.trackMouse();
        } else if (e.type === "mouseleave") {
          return this.stopTrackingMouse();
        }
      },
      onMouseMove: function(e) {
        var mousePos;
        mousePos = this.getMousePos(e.pageX);
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
        var noTodosAreSelected;
        noTodosAreSelected = !window.app.todos.any(function(model) {
          return model.get("selected");
        });
        if (noTodosAreSelected) {
          if (target === this.cid) {
            return console.log("Hover: Complete (None selected)");
          }
        } else if (this.model.get("selected")) {
          return console.log("Hover: Complete");
        }
      },
      onHoverSchedule: function(target) {
        var noTodosAreSelected;
        noTodosAreSelected = !window.app.todos.any(function(model) {
          return model.get("selected");
        });
        if (noTodosAreSelected) {
          if (target === this.cid) {
            return console.log("Hover: Schedule (None selected)");
          }
        } else if (this.model.get("selected")) {
          return console.log("Hover: Schedule");
        }
      },
      onUnhoverComplete: function(target) {
        var noTodosAreSelected;
        noTodosAreSelected = !window.app.todos.any(function(model) {
          return model.get("selected");
        });
        if (noTodosAreSelected) {
          if (target === this.cid) {
            return console.log("Unhover: Complete (None selected)");
          }
        } else if (this.model.get("selected")) {
          return console.log("Unhover: Complete");
        }
      },
      onUnhoverSchedule: function(target) {
        var noTodosAreSelected;
        noTodosAreSelected = !window.app.todos.any(function(model) {
          return model.get("selected");
        });
        if (noTodosAreSelected) {
          if (target === this.cid) {
            return console.log("Unhover: Schedule (None selected)");
          }
        } else if (this.model.get("selected")) {
          return console.log("Unhover: Schedule");
        }
      },
      customCleanUp: function() {
        $(window).off();
        return this.stopTrackingMouse();
      }
    });
  });

}).call(this);
