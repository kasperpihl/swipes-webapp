(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["jquery", "model/ListSortModel", "gsap", "gsap-draggable"], function($, ListSortModel, TweenLite, Draggable) {
    var ListSortController;
    return ListSortController = (function() {
      function ListSortController(container, views) {
        this.onDragStart = __bind(this.onDragStart, this);
        this.onClick = __bind(this.onClick, this);
        this.model = new ListSortModel(container, views);
        this.listenForOrderChanges();
        this.setInitialOrder();
        this.init();
      }

      ListSortController.prototype.setInitialOrder = function() {
        var view, _i, _len, _ref, _results;
        this.model.container.height("");
        this.model.container.height(this.model.container.height());
        _ref = this.model.views;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          view.$el.css({
            position: "absolute",
            width: "100%"
          });
          _results.push(this.reorderView.call(view, view.model, view.model.get("order"), false));
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
        _ref = this.model.views;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          dragOpts = {
            type: "top",
            bounds: this.model.container,
            edgeResistance: 0.75,
            throwProps: true,
            resistance: 3000,
            snap: {
              top: function(endValue) {
                return Math.max(this.minY, Math.min(this.maxY, Math.round(endValue / self.model.rowHeight) * self.model.rowHeight));
              }
            },
            onClickParams: [view],
            onClick: this.onClick,
            onDragStartParams: [view, this.model.views],
            onDragStart: this.onDragStart,
            onDragParams: [view, this.model],
            onDrag: this.onDrag,
            onDragEndParams: [view, this.model],
            onDragEnd: this.onDragEnd
          };
          dragOpts.trigger = view.$el.find(".todo-content");
          draggable = new Draggable(view.el, dragOpts);
          _results.push(this.draggables.push(draggable));
        }
        return _results;
      };

      ListSortController.prototype.listenForOrderChanges = function() {
        var view, _i, _len, _ref, _results;
        _ref = this.model.views;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          _results.push(view.model.on("change:order", this.reorderView, view));
        }
        return _results;
      };

      ListSortController.prototype.stopListenForOrderChanges = function() {
        var view, _i, _len, _ref, _results;
        _ref = this.model.views;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          _results.push(view.model.off(null, null, this));
        }
        return _results;
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
            return view.$el.addClass("selected");
          }
        }, 100);
      };

      ListSortController.prototype.onDrag = function(view, model) {
        model.reorderRows(view, this.y);
        return model.scrollWindow(this.pointerY);
      };

      ListSortController.prototype.onDragEnd = function(view, model) {
        model.reorderRows(view, this.endY);
        if (!view.model.get("selected")) {
          return view.$el.removeClass("selected");
        }
      };

      ListSortController.prototype.reorderView = function(model, newOrder, animate) {
        var dur;
        if (animate == null) {
          animate = true;
        }
        dur = animate ? 0.3 : 0;
        return TweenLite.to(this.el, dur, {
          top: newOrder * this.$el.height()
        });
      };

      ListSortController.prototype.destroy = function() {
        var draggable, _i, _len, _ref;
        this.stopListenForOrderChanges();
        _ref = this.draggables;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          draggable = _ref[_i];
          draggable.disable();
        }
        this.draggables = null;
        this.model.destroy();
        return this.model = null;
      };

      return ListSortController;

    })();
  });

}).call(this);
