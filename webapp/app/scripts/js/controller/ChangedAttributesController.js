(function() {
  define(["underscore", "backbone", "jquery", "plugins/lockablestorage"], function(_, Backbone, $) {
    var ChangedAttributesController;
    return ChangedAttributesController = (function() {
      function ChangedAttributesController() {
        this.localKey = "changedAttributesStore";
        _.bindAll(this, "saveAttributesToSync");
        this.newChangedAttributes = this.newCollection();
        this.tempChangedAttributes = this.newCollection();
      }

      /*		initializeChanges: ->
      			LockableStorage.lock( @localKey, =>
      				localStorage[@localKey] = 
      					"Tag": {} 
      					"ToDo": {}
      			)
      		getAllChanges: ->
      			localStorage.getItem( @localKey )
      */


      ChangedAttributesController.prototype.newCollection = function() {
        return {
          "ToDo": {},
          "Tag": {}
        };
      };

      ChangedAttributesController.prototype.getChangesForModel = function(model) {
        if (model.id != null) {
          return this.newChangedAttributes[model.className][model.id];
        } else if (model.get("tempId")) {
          return this.tempChangedAttributes[model.className][model.get("tempId")];
        }
        return null;
      };

      ChangedAttributesController.prototype.saveAttributesToSync = function(model, attributes) {
        console.log(_.keys(attributes));
        return this._saveAttributesForSyncing(this.newChangedAttributes, model, attributes);
      };

      ChangedAttributesController.prototype.saveTempAttributesToSync = function(model, attributes) {
        return this._saveAttributesForSyncing(this.tempChangedAttributes, model, attributes);
      };

      ChangedAttributesController.prototype._saveAttributesForSyncing = function(collection, model, attributes) {
        var currentChanges, identifier;
        identifier = model.id != null ? model.id : model.get("tempId");
        if (!identifier) {
          return;
        }
        currentChanges = collection[model.className][identifier];
        attributes = _.keys(attributes);
        if (currentChanges) {
          attributes = _.uniq(currentChanges.concat(attributes));
        }
        return collection[model.className][identifier] = attributes;
      };

      ChangedAttributesController.prototype.getIdentifiersAndAttributesForSyncing = function(reset) {
        var collection;
        collection = $.parseJSON(JSON.stringify(this.newChangedAttributes));
        if (reset) {
          this.newChangedAttributes = this.newCollection();
        }
        return collection;
      };

      ChangedAttributesController.prototype.moveTempChangesForModel = function(model) {
        var tempAttributes;
        if ((model.id == null) || !model.get("tempId" != null)) {
          return;
        }
        tempAttributes = this.tempChangedAttributes[model.className][model.get("tempId")];
        if ((tempAttributes != null) && tempAttributes.length > 0) {
          return saveAttributesToSync(model, tempAttributes);
        }
      };

      ChangedAttributesController.prototype.resetTempChanges = function() {
        return this.tempChangedAttributes = this.newCollection();
      };

      return ChangedAttributesController;

    })();
  });

}).call(this);
