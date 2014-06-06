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
        this.needSync = false;
        this.lastUpdate = null;
        this.sync();
        this.bouncedSync = _.debounce(this.sync, 3000);
      }

      SyncController.prototype.handleModelForSync = function(model, attributes) {
        if (model.id) {
          this.changedAttributes.saveAttributesToSync(model, attributes);
        } else if (this.isSyncing) {
          this.changedAttributes.saveTempAttributesToSync(model, attributes);
        }
        console.log("handling");
        return this.bouncedSync();
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

      SyncController.prototype.prepareNewObjectsForCollection = function(collection) {
        var json, mdl, newModels, serverJSON, _i, _len;
        newModels = collection.filter(function(model) {
          return !model.id && model.get("tempId");
        });
        serverJSON = [];
        for (_i = 0, _len = newModels.length; _i < _len; _i++) {
          mdl = newModels[_i];
          json = mdl.toServerJSON();
          serverJSON.push(json);
        }
        return serverJSON;
      };

      SyncController.prototype.prepareUpdatesForCollection = function(collection, className) {
        var identifiers, json, mdl, mdlsChanges, serverJSON, updateModels, updatedAttributes, _i, _len;
        updatedAttributes = this.changedAttributes.newChangedAttributes[className];
        identifiers = _.keys(updatedAttributes);
        serverJSON = [];
        updateModels = collection.filter(function(model) {
          return _.indexOf(identifiers, model.id) !== -1;
        });
        for (_i = 0, _len = updateModels.length; _i < _len; _i++) {
          mdl = updateModels[_i];
          mdlsChanges = updatedAttributes[mdl.id];
          json = _.pick(mdl.toServerJSON(), mdlsChanges);
          json.objectId = mdl.id;
          serverJSON.push(json);
        }
        return serverJSON;
      };

      SyncController.prototype.prepareObjectsToSaveOnServer = function() {
        var newTags, newTodos, serverJSON, updateTags, updateTodos;
        console.log("prepare");
        if (typeof swipy === "undefined" || swipy === null) {
          this.needSync = true;
          return;
        }
        newTags = this.prepareNewObjectsForCollection(swipy.tags);
        newTodos = this.prepareNewObjectsForCollection(swipy.todos);
        updateTags = this.prepareUpdatesForCollection(swipy.tags, "Tag");
        updateTodos = this.prepareUpdatesForCollection(swipy.todos, "ToDo");
        serverJSON = {
          ToDo: newTags.concat(updateTags),
          Tag: newTodos.concat(updateTodos)
        };
        return serverJSON;
      };

      SyncController.prototype.sync = function() {
        var data, isSyncing, objects, serData, settings, token, url, user;
        console.log("syncing");
        if (isSyncing) {
          return this.needSync = true;
        }
        isSyncing = true;
        url = "http://localhost:5000/sync";
        user = Parse.User.current();
        token = user.getSessionToken();
        data = {
          sessionToken: token,
          platform: "web",
          sendLogs: true,
          changesOnly: true
        };
        if (this.lastUpdate) {
          data.lastUpdate = this.lastUpdate;
        }
        objects = this.prepareObjectsToSaveOnServer();
        if (objects) {
          data.objects = objects;
        }
        serData = JSON.stringify(data);
        console.log(serData);
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
        return $.ajax(settings);
      };

      SyncController.prototype.finalizeSync = function() {
        this.isSyncing = false;
        if (this.needSync) {
          this.needSync = false;
          return this.sync(true);
        }
      };

      SyncController.prototype.errorFromSync = function(data, textStatus, error) {
        this.finalizeSync();
        return console.log(error);
      };

      SyncController.prototype.responseFromSync = function(data, textStatus) {
        console.log(data);
        if (data && data.serverTime) {
          if (data.Tag != null) {
            this.handleObjectsFromSync(data.Tag, "Tag");
          }
          if (data.ToDo != null) {
            this.handleObjectsFromSync(data.ToDo, "ToDo");
          }
          console.log(data);
          if (data.updateTime) {
            this.lastUpdate = data.updateTime;
          }
        }
        return this.finalizeSync();
      };

      return SyncController;

    })();
  });

}).call(this);
