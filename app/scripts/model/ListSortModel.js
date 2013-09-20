(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    var ListSortModel;
    return ListSortModel = (function() {
      function ListSortModel(container, views) {
        var view, _i, _len, _ref;
        this.container = container;
        this.views = views;
        this.rows = this.getRows();
        this.setRowTops();
        console.groupCollapsed("Starting with order: ");
        _ref = this.views;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          console.log(view.model.get("title") + ": " + view.model.get("order"));
        }
        console.groupEnd();
      }

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

      ListSortModel.prototype.setRowTops = function() {
        var view, _i, _len, _ref;
        _ref = this.views;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          view.top = parseInt(view.$el.position().top);
        }
        return this.views;
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
            affectedView.model.set("order", affectedView.model.get("order") + 1);
          }
        } else if (newOrder > oldOrder) {
          _ref1 = this.getViewsBetween(oldOrder, newOrder, view.model.cid);
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            affectedView = _ref1[_j];
            affectedView.model.set("order", affectedView.model.get("order") - 1);
          }
        }
        return view.model.set({
          order: newOrder
        }, {
          silent: true
        });
      };

      ListSortModel.prototype.destroy = function() {};

      return ListSortModel;

    })();
  });

}).call(this);
