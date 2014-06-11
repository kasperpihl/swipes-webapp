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
        this.currentSyncing = null;
      }

      SyncController.prototype.handleModelForSync = function(model, attributes) {
        if (model.id) {
          this.changedAttributes.saveAttributesToSync(model, attributes);
        } else if (this.isSyncing && !model.id) {
          this.changedAttributes.saveTempAttributesToSync(model, attributes);
        }
        return this.bouncedSync();
      };

      SyncController.prototype.handleObjectsFromSync = function(objects, className) {
        var collection, model, newModels, obj, objectId, recentChanges, tempId, _i, _len;
        collection = className === "ToDo" ? swipy.todos : swipy.tags;
        newModels = [];
        for (_i = 0, _len = objects.length; _i < _len; _i++) {
          obj = objects[_i];
          objectId = obj.objectId;
          tempId = obj.tempId;
          model = collection.find(function(model) {
            if ((objectId != null) && model.id === objectId) {
              return true;
            }
            if ((tempId != null) && model.get("tempId") === tempId) {
              return true;
            }
            return false;
          });
          if (!model) {
            if (obj.deleted) {
              continue;
            }
            model = new collection.model(obj);
            this.changedAttributes.moveTempChangesForModel(model);
            newModels.push(model);
          } else {
            recentChanges = this.changedAttributes.getChangesForModel(model);
            model.updateFromServerObj(obj, recentChanges);
          }
        }
        if (newModels.length > 0) {
          return collection.add(newModels);
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
        var attr, deleteJSON, identifiers, json, mdl, mdlsChanges, objID, serverJSON, updateModels, updatedAttributes, _i, _len;
        updatedAttributes = this.currentSyncing[className];
        serverJSON = [];
        for (objID in updatedAttributes) {
          attr = updatedAttributes[objID];
          if (_.indexOf(attr, "deleted") !== -1) {
            deleteJSON = {
              objectId: objID,
              deleted: true
            };
            serverJSON.push(deleteJSON);
          }
        }
        identifiers = _.keys(updatedAttributes);
        updateModels = collection.filter(function(model) {
          return _.indexOf(identifiers, model.id) !== -1;
        });
        for (_i = 0, _len = updateModels.length; _i < _len; _i++) {
          mdl = updateModels[_i];
          mdlsChanges = updatedAttributes[mdl.id];
          json = mdl.toServerJSON(mdlsChanges);
          json.objectId = mdl.id;
          serverJSON.push(json);
        }
        return serverJSON;
      };

      SyncController.prototype.combineAttributes = function(newAttributes) {
        var className, existingChanges, identifier, newChanges, _i, _len, _ref, _results;
        if (this.currentSyncing == null) {
          return this.currentSyncing = newAttributes;
        }
        _ref = ["Tag", "ToDo"];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          className = _ref[_i];
          _results.push((function() {
            var _ref1, _results1;
            _ref1 = newAttributes[className];
            _results1 = [];
            for (identifier in _ref1) {
              newChanges = _ref1[identifier];
              existingChanges = this.currentSyncing[className][identifier];
              if (existingChanges != null) {
                newChanges = _.uniq(existingChanges.concat(newChanges));
              }
              _results1.push(this.currentSyncing[className][identifier] = newChanges);
            }
            return _results1;
          }).call(this));
        }
        return _results;
      };

      SyncController.prototype.prepareObjectsToSaveOnServer = function() {
        var newAttributes, newTags, newTodos, serverJSON, updateTags, updateTodos;
        if (typeof swipy === "undefined" || swipy === null) {
          return;
        }
        newAttributes = this.changedAttributes.getIdentifiersAndAttributesForSyncing("reset");
        this.combineAttributes(newAttributes);
        newTags = this.prepareNewObjectsForCollection(swipy.tags);
        newTodos = this.prepareNewObjectsForCollection(swipy.todos);
        updateTags = this.prepareUpdatesForCollection(swipy.tags, "Tag");
        updateTodos = this.prepareUpdatesForCollection(swipy.todos, "ToDo");
        serverJSON = {
          Tag: newTags.concat(updateTags),
          ToDo: newTodos.concat(updateTodos)
        };
        return serverJSON;
      };

      SyncController.prototype.sync = function() {
        var data, objects, serData, settings, token, url, user;
        if (this.isSyncing) {
          return this.needSync = true;
        }
        this.isSyncing = true;
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
        console.log(data);
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

      SyncController.prototype.finalizeSync = function(error) {
        this.isSyncing = false;
        this.changedAttributes.resetTempChanges();
        if (this.needSync) {
          this.needSync = false;
          this.sync(true);
        }
        return Backbone.trigger("sync-complete", this);
      };

      SyncController.prototype.errorFromSync = function(data, textStatus, error) {
        this.finalizeSync();
        return console.log(error);
      };

      SyncController.prototype.responseFromSync = function(data, textStatus) {
        console.log(data);
        if (data && data.serverTime) {
          this.currentSyncing = null;
          if (data.Tag != null) {
            this.handleObjectsFromSync(data.Tag, "Tag");
          }
          if (data.ToDo != null) {
            this.handleObjectsFromSync(data.ToDo, "ToDo");
          }
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
