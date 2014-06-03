/*
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync
*/


(function() {
  define(["underscore", "backbone", "jquery"], function(_, Backbone, $) {
    var SyncController;
    return SyncController = (function() {
      function SyncController() {
        this.lastUpdate = null;
        this.sync();
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

      SyncController.prototype.handleModelForSync = function(model) {
        return console.log(model);
      };

      SyncController.prototype.prepareObjects = function() {
        return console.log("prepare");
      };

      SyncController.prototype.sync = function() {
        var data, serData, settings, token, url, user;
        url = "http://localhost:5000/v1/sync";
        user = Parse.User.current();
        token = user.getSessionToken();
        data = {
          sessionToken: token
        };
        serData = JSON.stringify(data);
        settings = {
          url: url,
          type: 'POST',
          success: this.responseFromSync,
          error: this.errorFromSync,
          dataType: "json",
          contentType: "application/json; charset=utf-8",
          crossDomain: true,
          data: serData,
          processData: false
        };
        $.ajax(settings);
        if (this.lastUpdate != null) {
          return this.prepareObjects();
        }
      };

      SyncController.prototype.errorFromSync = function(data, textStatus, error) {};

      SyncController.prototype.responseFromSync = function(data, textStatus) {
        if (data && data.serverTime) {
          console.log(data.Tag);
        }
        return console.log(data);
      };

      return SyncController;

    })();
  });

}).call(this);
