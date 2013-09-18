(function() {
  define(["jquery", "gsap-draggable"], function($, Draggable) {
    var ListSortController;
    return ListSortController = (function() {
      function ListSortController(container, elements) {
        this.container = container;
        this.elements = elements;
        this.rowHeight = this.elements.first().height();
        this.init();
      }

      ListSortController.prototype.init = function() {
        var dragOpts, el, self, _i, _len, _ref, _results;
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
          onDragStart: function() {
            return console.log("Drag started ", this);
          },
          onDrag: function() {
            return console.log("Dragged ", this);
          },
          onDragEnd: function() {
            return console.log("Drag ended ", this);
          }
        };
        this.draggables = [];
        _ref = this.elements;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          el = _ref[_i];
          dragOpts.trigger = $(el).find(".todo-content");
          _results.push(this.draggables.push(Draggable.create(el, dragOpts)));
        }
        return _results;
      };

      ListSortController.prototype.destroy = function() {
        return this.draggables = null;
      };

      return ListSortController;

    })();
  });

}).call(this);
