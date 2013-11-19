(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["jquery", "model/ListSortModel", "gsap", "gsap-draggable", "hammerjs"], function($, ListSortModel, TweenLite, Draggable) {
    var ListSortController;
    return ListSortController = (function() {
      function ListSortController(container, views, onDragCompleteCallback) {
        this.onDragCompleteCallback = onDragCompleteCallback;
        this.onDragStart = __bind(this.onDragStart, this);
        this.deactivate = __bind(this.deactivate, this);
        this.activate = __bind(this.activate, this);
        this.model = new ListSortModel(container, views);
        this.enableTouchListners();
      }

      ListSortController.prototype.enableTouchListners = function() {
        return $(this.model.container[0]).hammer().on("hold", "ol li", this.activate);
      };

      ListSortController.prototype.disableTouchListeners = function() {
        return $(this.model.container[0]).hammer().off("hold", this.activate);
      };

      ListSortController.prototype.activate = function(e) {
        this.disableTouchListeners();
        this.model.init();
        Backbone.on("redraw-sortable-list", this.redraw, this);
        this.listenForOrderChanges();
        this.setInitialOrder();
        this.createDraggable(this.model.getViewFromId(e.currentTarget.getAttribute("data-id")));
        if (e) {
          return this.draggable.startDrag(e.gesture.srcEvent);
        }
      };

      ListSortController.prototype.deactivate = function(removeCSS) {
        if (removeCSS == null) {
          removeCSS = false;
        }
        this.stopListenForOrderChanges();
        this.killDraggable(removeCSS);
        Backbone.off("redraw-sortable-list", this.redraw);
        this.model.destroy();
        return this.enableTouchListners();
      };

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

      ListSortController.prototype.createDraggable = function(view) {
        var dragOpts, self,
          _this = this;
        if (this.draggable != null) {
          this.killDraggable();
        }
        self = this;
        dragOpts = {
          type: "y",
          bounds: this.model.container,
          edgeResistance: 0.75,
          throwProps: true,
          resistance: 3000,
          snap: {
            y: function(endValue) {
              return Math.max(this.minY, Math.min(this.maxY, Math.round(endValue / self.model.rowHeight) * self.model.rowHeight));
            }
          },
          onDragStartParams: [view, this.model.views],
          onDragStart: this.onDragStart,
          onDragParams: [view, this.model],
          onDrag: this.onDrag,
          onDragEndParams: [view, this.model],
          onDragEnd: this.onDragEnd,
          onThrowComplete: function() {
            var _ref;
            _this.deactivate();
            return (_ref = _this.onDragCompleteCallback) != null ? _ref.call(_this) : void 0;
          }
        };
        dragOpts.trigger = view.$el.find(".todo-content");
        return this.draggable = new Draggable(view.el, dragOpts);
      };

      ListSortController.prototype.redraw = function() {
        this.killDraggable();
        this.model.rows = this.model.getRows();
        return this.setInitialOrder();
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
        var view, _i, _len, _ref, _ref1, _results;
        if (this.model != null) {
          _ref1 = (_ref = this.model) != null ? _ref.views : void 0;
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            view = _ref1[_i];
            _results.push(view.model.off(null, null, this));
          }
          return _results;
        }
      };

      ListSortController.prototype.onDragStart = function(view, allViews) {
        return view.$el.addClass("selected");
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
          y: newOrder * this.$el.height()
        });
      };

      ListSortController.prototype.killDraggable = function(removeCSS) {
        if (this.draggable != null) {
          this.draggable.disable();
          this.draggable = null;
          if (removeCSS) {
            return this.removeInlineStyles();
          }
        }
      };

      ListSortController.prototype.removeInlineStyles = function() {
        var view, _i, _len, _ref, _results;
        _ref = this.model.views;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          _results.push(view.$el.removeAttr("style"));
        }
        return _results;
      };

      ListSortController.prototype.destroy = function() {
        this.deactivate(true);
        this.disableTouchListeners();
        return this.model = null;
      };

      return ListSortController;

    })();
  });

}).call(this);
