(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    var FilterController;
    return FilterController = (function() {
      function FilterController() {
        this.tagsFilter = [];
        this.searchFilter = "";
        this.debouncedSearch = _.debounce(this.applySearchFilter, 100);
        this.debouncedClearSearch = _.debounce(this.removeSearchFilter, 100);
        Backbone.on("apply-filter", this.applyFilter, this);
        Backbone.on("remove-filter", this.removeFilter, this);
        Backbone.on('navigate/view', this.clearFilters, this);
      }

      FilterController.prototype.applyFilter = function(type, filter) {
        if (type === "tag") {
          return this.applyTagsFilter(filter);
        } else {
          return this.debouncedSearch(filter);
        }
      };

      FilterController.prototype.removeFilter = function(type, filter) {
        if (type === "tag") {
          return this.removeTagsFilter(filter);
        } else {
          return this.debouncedClearSearch(filter);
        }
      };

      FilterController.prototype.clearFilters = function() {
        if (this.searchFilter.length) {
          this.removeSearchFilter();
        }
        if (this.tagsFilter.length) {
          this.tagsFilter = [];
          return this.removeTagsFilter();
        }
      };

      FilterController.prototype.applyTagsFilter = function(addTag) {
        var reject, task, _i, _len, _ref, _results;
        if (addTag && !_.contains(this.tagsFilter, addTag)) {
          this.tagsFilter.push(addTag);
        }
        _ref = swipy.todos.models;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          task = _ref[_i];
          reject = true;
          if (task.has("tags") && _.intersection(task.getTagStrList(), this.tagsFilter).length === this.tagsFilter.length) {
            reject = false;
          }
          _results.push(task.set("rejectedByTag", reject));
        }
        return _results;
      };

      FilterController.prototype.applySearchFilter = function(filter) {
        var _this = this;
        this.searchFilter = filter;
        return swipy.todos.each(function(model) {
          var isRejected;
          isRejected = model.get("title").toLowerCase().indexOf(_this.searchFilter) === -1;
          return model.set("rejectedBySearch", isRejected);
        });
      };

      FilterController.prototype.removeTagsFilter = function(tag) {
        this.tagsFilter = _.without(this.tagsFilter, tag);
        if (this.tagsFilter.length === 0) {
          return swipy.todos.invoke("set", "rejectedByTag", false);
        } else {
          return this.applyTagsFilter();
        }
      };

      FilterController.prototype.removeSearchFilter = function(filter) {
        this.searchFilter = "";
        return swipy.todos.invoke("set", "rejectedBySearch", false);
      };

      FilterController.prototype.destroy = function() {
        return Backbone.off(null, null, this);
      };

      return FilterController;

    })();
  });

}).call(this);
