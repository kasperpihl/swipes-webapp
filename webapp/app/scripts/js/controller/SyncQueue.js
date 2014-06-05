(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    var SyncQueue;
    return SyncQueue = (function() {
      function SyncQueue() {
        this.deferreds = [];
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
        return this.deferreds.push(dfd);
      };

      SyncQueue.prototype.isBusy = function() {
        return _.any(this.deferreds, function(d) {
          return d.state() === "pending";
        });
      };

      SyncQueue.prototype.destroy = function() {};

      return SyncQueue;

    })();
  });

}).call(this);
