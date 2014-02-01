(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    var SyncQueue;
    return SyncQueue = (function() {
      SyncQueue.prototype.state = "";

      SyncQueue.prototype.deferreds = [];

      function SyncQueue() {
        this.state = "ready";
      }

      SyncQueue.prototype.add = function(promise) {
        var dfd, fail, success;
        dfd = new $.Deferred();
        success = function() {
          return dfd.resolve();
        };
        fail = function() {
          return dfd.reject();
        };
        promise.then(success, fail);
        return this.deferreds.push(dfd.promise());
      };

      SyncQueue.prototype.isBusy = function() {
        return !_.all(this.deferreds, function(d) {
          return d.isResolved() || d.isRejected();
        });
      };

      SyncQueue.prototype.destroy = function() {};

      return SyncQueue;

    })();
  });

}).call(this);
