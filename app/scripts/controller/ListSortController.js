(function() {
  define(["jquery", "gsap", "gsap-draggable"], function($, TweenLite, Draggable) {
    var ListSortController;
    return ListSortController = (function() {
      function ListSortController(container, views) {
        this.container = container;
        this.views = views;
        this.rowHeight = this.views[0].$el.height();
        this.disableNativeClickHandlers();
        this.init();
      }

      ListSortController.prototype.disableNativeClickHandlers = function() {
        var view, _i, _len, _ref, _results;
        _ref = this.views;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          _results.push(console.log("Disable native click event"));
        }
        return _results;
      };

      ListSortController.prototype.init = function() {
        var dragOpts, self, view, _i, _len, _ref, _results;
        if (this.draggables != null) {
          this.destroy();
        }
        self = this;
        dragOpts = {
          type: "y",
          bounds: this.container,
          edgeResistance: 0.75,
          throwProps: true,
          snap: {
            y: function(endValue) {
              return Math.max(this.minY, Math.min(this.maxY, Math.round(endValue / self.rowHeight) * self.rowHeight));
            }
          },
          onClick: function(view, allViews) {
            return console.log("Clicked ", view);
          },
          onDragStart: function() {
            return TweenLite.to(this.target, 0.15, {
              scale: 1.1,
              boxShadow: "0px 0px 15px 1px rgba(0,0,0,0.2)"
            });
          },
          onDrag: function(view, allViews) {
            return console.log("Dragged ", this);
          },
          onDragEnd: function(view, allViews) {
            return TweenLite.to(this.target, 0.25, {
              scale: 1,
              boxShadow: "none"
            });
          }
        };
        this.draggables = [];
        _ref = this.views;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          dragOpts.onClickParams = dragOpts.onDragParams = [view, this.views];
          dragOpts.trigger = view.$el.find(".todo-content");
          _results.push(this.draggables.push(Draggable.create(view.$el, dragOpts)));
        }
        return _results;
      };

      ListSortController.prototype.destroy = function() {
        var draggable, _i, _len, _ref;
        _ref = this.draggables;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          draggable = _ref[_i];
          draggable.disable();
        }
        return this.draggables = null;
      };

      return ListSortController;

    })();
  });

}).call(this);
