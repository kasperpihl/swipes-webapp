/*
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync
*/


(function() {
  define(["underscore", "backbone", "jquery", "js/controller/ChangedAttributesController"], function(_, Backbone, $, ChangedAttributesController) {
    var SyncController;
    return SyncController = (function() {
      function SyncController() {
        this.changedAttributes = new ChangedAttributesController();
        this.isSyncing = false;
        this.lastUpdate = null;
        this.sync();
      }

      SyncController.prototype.handleModelForSync = function(model, attributes) {
        this.changedAttributes.saveAttributesToSync(model, attributes);
        return console.log(this.changedAttributes.changedAttributes);
      };

      SyncController.prototype.handleObjectsFromSync = function(objects, className) {
        var collection, model, newModels, obj, objectId, tempId, _i, _len;
        collection = className === "ToDo" ? swipy.todos : swipy.tags;
        newModels = [];
        for (_i = 0, _len = objects.length; _i < _len; _i++) {
          obj = objects[_i];
          objectId = obj.objectId;
          tempId = obj.tempId;
          model = collection.find(function(model) {
            if (model.id === objectId || model.get('tempId' === tempId)) {
              return true;
            } else {
              return false;
            }
          });
          if (!model) {
            model = new collection.model(obj);
            newModels.push(model);
          }
        }
        if (newModels.length > 0) {
          collection.add(newModels, {
            silent: true
          });
          return collection.trigger("reset");
        }
      };

      SyncController.prototype.prepareObjects = function() {
        return console.log("prepare");
      };

      SyncController.prototype.sync = function() {
        var data, isSyncing, serData, settings, token, url, user;
        if (isSyncing) {
          return;
        }
        isSyncing = true;
        url = "http://localhost:5000/sync";
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
          context: this,
          data: serData,
          processData: false
        };
        $.ajax(settings);
        if (this.lastUpdate != null) {
          return this.prepareObjects();
        }
      };

      SyncController.prototype.errorFromSync = function(data, textStatus, error) {
        this.isSyncing = false;
        return console.log(error);
      };

      SyncController.prototype.responseFromSync = function(data, textStatus) {
        this.isSyncing = false;
        if (data && data.serverTime) {
          this.handleObjectsFromSync(data.Tag, "Tag");
          this.handleObjectsFromSync(data.ToDo, "ToDo");
          if (data.updatedTime) {
            return this.lastUpdate = data.updatedTime;
          }
        }
      };

      return SyncController;

    })();
  });

}).call(this);
