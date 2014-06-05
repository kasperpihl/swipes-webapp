(function() {
  define(["underscore", "backbone", "jquery", "plugins/lockablestorage"], function(_, Backbone, $) {
    var ChangedAttributesController;
    return ChangedAttributesController = (function() {
      function ChangedAttributesController() {
        this.localKey = "changedAttributesStore";
        _.bindAll(this, "saveAttributesToSync");
        this.newChangedAttributes = {
          "ToDo": {},
          "Tag": {}
        };
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


      ChangedAttributesController.prototype.saveAttributesToSync = function(model, attributes) {
        var currentChanges;
        if (!model.id) {
          return;
        }
        currentChanges = this.newChangedAttributes[model.className][model.id];
        if (currentChanges) {
          attributes = _.uniq(attributes.concat(currentChanges));
        }
        return this.newChangedAttributes[model.className][model.id] = _.keys(attributes);
      };

      return ChangedAttributesController;

    })();
  });

}).call(this);
