/*
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync
*/


(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    var SyncController;
    return SyncController = (function() {
      function SyncController() {
        this.test = "yeah";
      }

      SyncController.prototype.saveToSync = function(objects) {
        var object, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = objects.length; _i < _len; _i++) {
          object = objects[_i];
          _results.push(this.handleModelForSync(object));
        }
        return _results;
      };

      SyncController.prototype.handleModelForSync = function(model) {};

      return SyncController;

    })();
  });

}).call(this);
