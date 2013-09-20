(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["jquery", "gsap", "gsap-draggable"], function($, TweenLite, Draggable) {
    var ListSortController;
    return ListSortController = (function() {
      function ListSortController(container, views) {
        this.container = container;
        this.views = views;
        this.onDragStart = __bind(this.onDragStart, this);
        this.onClick = __bind(this.onClick, this);
        this.rows = this.getRows();
        this.disableNativeClickHandlers();
        this.setViewTops();
        this.init();
      }

      ListSortController.prototype.getRows = function() {
        var i, rows, view;
        this.rowHeight = this.views[0].$el.height();
        rows = (function() {
          var _i, _len, _ref, _results;
          _ref = this.views;
          _results = [];
          for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
            view = _ref[i];
            _results.push(i * this.rowHeight);
          }
          return _results;
        }).call(this);
        return rows;
      };

      ListSortController.prototype.setViewTops = function() {
        var view, _i, _len, _ref;
        _ref = this.views;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          view.top = parseInt(view.$el.position().top);
        }
      };

      ListSortController.prototype.disableNativeClickHandlers = function() {
        var view, _i, _len, _ref, _results;
        _ref = this.views;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          view.undelegateEvents();
          delete view.events.click;
          delete view.events.tap;
          _results.push(view.delegateEvents());
        }
        return _results;
      };

      ListSortController.prototype.init = function() {
        var dragOpts, draggable, self, view, _i, _len, _ref, _results;
        if (this.draggables != null) {
          this.destroy();
        }
        self = this;
        this.draggables = [];
        _ref = this.views;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          dragOpts = {
            type: "top",
            bounds: this.container,
            zIndexBoost: false,
            edgeResistance: 0.75,
            throwProps: true,
            resistance: 3000,
            snap: {
              top: function(endValue) {
                return Math.max(this.minY, Math.min(this.maxY, Math.round(endValue / self.rowHeight) * self.rowHeight));
              }
            },
            onClickParams: [view],
            onClick: this.onClick,
            onDragStartParams: [view, this.views],
            onDragStart: this.onDragStart,
            onDragParams: [view, this.views],
            onDrag: this.onDrag,
            onDragEnd: this.onDragEnd
          };
          dragOpts.trigger = view.$el.find(".todo-content");
          draggable = new Draggable(view.el, dragOpts);
          _results.push(this.draggables.push(draggable));
        }
        return _results;
      };

      ListSortController.prototype.getOrderValForView = function(view) {
        return console.log("Get order value for ", view);
      };

      ListSortController.prototype.onClick = function(view, allViews) {
        var _this = this;
        this.clicked = view.cid;
        view.toggleSelected();
        return setTimeout((function() {
          return _this.clicked = false;
        }), 400);
      };

      ListSortController.prototype.onDragStart = function(view, allViews) {
        var _this = this;
        return setTimeout(function() {
          if (!(_this.clicked && _this.clicked === view.cid)) {
            return TweenLite.to(view.el, 0.1, {
              scale: 1.05,
              zIndex: 3,
              boxShadow: "0px 0px 15px 1px rgba(0,0,0,0.1)"
            });
          }
        }, 100);
      };

      ListSortController.prototype.onDrag = function(view, allViews) {
        var truePos;
        truePos = this.y + view.top;
        return console.log("True position: " + truePos + "px / y: " + this.y);
      };

      ListSortController.prototype.onDragEnd = function(view, allViews) {
        return TweenLite.to(this.target, 0.25, {
          scale: 1,
          zIndex: "",
          boxShadow: "0 0 0 transparent"
        });
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
