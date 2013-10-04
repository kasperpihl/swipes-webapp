(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    var FilterController;
    return FilterController = (function() {
      function FilterController() {
        this.tagsFilter = [];
        this.searchFilter = "";
        Backbone.on("apply-filter", this.applyFilter, this);
        Backbone.on("remove-filter", this.removeFilter, this);
      }

      FilterController.prototype.applyFilter = function(type, filter) {
        if (type === "tags") {
          return this.applyTagsFilter(filter);
        } else {
          return this.applySearchFilter(filter);
        }
      };

      FilterController.prototype.removeFilter = function(type, filter) {
        if (type === "tags") {
          return this.removeTagsFilter(filter);
        } else {
          return this.removeSearchFilter(filter);
        }
      };

      FilterController.prototype.applyTagsFilter = function(filter) {
        return console.log("Apply tags filter for " + filter);
      };

      FilterController.prototype.applySearchFilter = function(filter) {
        return console.log("Apply search filter for: " + filter);
      };

      FilterController.prototype.removeTagsFilter = function(filter) {
        return console.log("Remove tags filter for " + filter);
      };

      FilterController.prototype.removeSearchFilter = function(filter) {
        return console.log("Remove search filter for: " + filter);
      };

      FilterController.prototype.getTasksThatMatchTags = function(tagsArr) {};

      return FilterController;

    })();
  });

}).call(this);
