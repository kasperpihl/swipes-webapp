(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["underscore", "backbone", "gsap-scroll", "gsap"], function(_, Backbone) {
    var ListSortModel;
    return ListSortModel = (function() {
      ListSortModel.HEIGHT_BREAKPOINT = 800;

      function ListSortModel(container, views) {
        this.container = container;
        this.setBounds = __bind(this.setBounds, this);
        this.active = false;
        this.setViews(views);
      }

      ListSortModel.prototype.setViews = function(views) {
        this.views = views;
        if (this.active) {
          this.rows = this.getRows();
          return this.setBounds();
        }
      };

      ListSortModel.prototype.init = function() {
        var debouncedSetBounds,
          _this = this;
        this.rows = this.getRows();
        this.setBounds();
        debouncedSetBounds = _.debounce(this.setBounds, 300);
        $(window).on("resize.sortmodel scroll.sortmodel", function() {
          return debouncedSetBounds();
        });
        this.currRowHeight = window.innerHeight < ListSortModel.HEIGHT_BREAKPOINT ? "small" : "big";
        $(window).on("resize.sortmodel", function() {
          if (window.innerHeight < ListSortModel.HEIGHT_BREAKPOINT && _this.currRowHeight !== "small") {
            _this.currRowHeight = "small";
            return Backbone.trigger("redraw-sortable-list");
          } else if (window.innerHeight >= ListSortModel.HEIGHT_BREAKPOINT && _this.currRowHeight !== "big") {
            _this.currRowHeight = "big";
            return Backbone.trigger("redraw-sortable-list");
          }
        });
        return this.active = true;
      };

      ListSortModel.prototype.getRows = function() {
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

      ListSortModel.prototype.setBounds = function() {
        var bounds;
        bounds = (this.container[0].getClientRects()[0] != null) || {
          top: 0
        };
        return this.bounds = {
          top: window.pageYOffset,
          bottom: window.innerHeight + window.pageYOffset
        };
      };

      ListSortModel.prototype.getViewAtPos = function(order) {
        var view, _i, _len, _ref;
        _ref = this.views;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          if (view.model.get("order") === order) {
            return view;
          }
        }
      };

      ListSortModel.prototype.getViewFromId = function(id) {
        var view, _i, _len, _ref;
        _ref = this.views;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          if (view.el.getAttribute("data-id") === id) {
            return view;
          }
        }
      };

      ListSortModel.prototype.getViewsBetween = function(min, max, excludeId) {
        var order, view, views, _i, _len, _ref;
        views = [];
        _ref = this.views;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          if (!(view.model.cid !== excludeId)) {
            continue;
          }
          order = view.model.get("order");
          if ((min <= order && order <= max)) {
            views.push(view);
          }
        }
        return views;
      };

      ListSortModel.prototype.getOrderFromPos = function(yPos) {
        var dist, distances, distancesWithIndex, index, minDist, obj, rowTop, _i, _j, _len, _len1, _ref;
        distances = [];
        distancesWithIndex = [];
        _ref = this.rows;
        for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
          rowTop = _ref[index];
          dist = Math.abs(yPos - rowTop);
          distances.push(dist);
          distancesWithIndex.push({
            index: index,
            dist: dist
          });
        }
        minDist = Math.min.apply(Math, distances);
        for (_j = 0, _len1 = distancesWithIndex.length; _j < _len1; _j++) {
          obj = distancesWithIndex[_j];
          if (obj.dist === minDist) {
            return obj.index;
          }
        }
      };

      ListSortModel.prototype.reorderRows = function(view, yPos) {
        var affectedView, newOrder, oldOrder, _i, _j, _len, _len1, _ref, _ref1;
        newOrder = this.getOrderFromPos(yPos);
        oldOrder = view.model.get("order");
        if (newOrder === oldOrder) {
          return;
        }
        if (newOrder < oldOrder) {
          _ref = this.getViewsBetween(newOrder, oldOrder, view.model.cid);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            affectedView = _ref[_i];
            affectedView.model.updateOrder(affectedView.model.get("order") + 1);
          }
        } else if (newOrder > oldOrder) {
          _ref1 = this.getViewsBetween(oldOrder, newOrder, view.model.cid);
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            affectedView = _ref1[_j];
            affectedView.model.updateOrder(affectedView.model.get("order") - 1);
          }
        }
        return view.model.updateOrder(newOrder, {
          silent: true
        });
      };

      ListSortModel.prototype.scrollWindow = function(minY, maxY, y, pointerY) {
        var amount, delta, distToBottom, distToTop, maxAmount, minAmount, newScroll, trigger;
        amount = minAmount = 20;
        maxAmount = 100;
        trigger = window.innerHeight * 0.3;
        if (this.oldTaskY) {
          delta = Math.abs(this.oldTaskY - y);
          amount = delta;
          if (delta < minAmount) {
            distToTop = pointerY - this.bounds.top;
            distToBottom = this.bounds.bottom - y;
            if (distToTop < distToBottom) {
              if (distToTop < (trigger * 0.8)) {
                amount = (trigger - distToTop) * 0.05;
              }
            } else {
              if (distToBottom < (trigger * 0.8)) {
                amount = (trigger - distToBottom) * 0.05;
              }
            }
          }
          amount = Math.max(5, Math.min(maxAmount, amount));
        }
        if (pointerY - trigger < this.bounds.top) {
          newScroll = window.pageYOffset - amount;
        } else if (pointerY + trigger > this.bounds.bottom) {
          newScroll = window.pageYOffset + amount;
        }
        TweenLite.set(window, {
          scrollTo: newScroll
        });
        return this.oldTaskY = y;
      };

      ListSortModel.prototype.destroy = function() {
        $(window).off(".sortmodel");
        return this.active = false;
      };

      return ListSortModel;

    })();
  });

}).call(this);
