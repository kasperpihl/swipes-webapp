(function() {
  define(["js/utility/Utility", "backbone"], function(Utility) {
    return Backbone.Model.extend({
      className: "BaseModel",
      defaultAttributes: ["objectId", "tempId", "deleted"],
      sync: function() {
        return true;
      },
      constructor: function(attributes) {
        var util;
        if (attributes && !attributes.objectId) {
          util = new Utility();
          attributes.tempId = util.generateId(12);
          console.log("generated tempId " + this.className + " - " + attributes.tempId);
        }
        return Backbone.Model.apply(this, arguments);
      },
      handleForSync: function(key, val, options) {
        var attrs;
        attrs = {};
        if (key === null || typeof key === 'object') {
          attrs = key;
          options = val;
        } else {
          attrs[key] = val;
        }
        if (options) {
          if (options.sync) {
            if (this.id) {
              return swipy.sync.handleModelForSync(this, attrs);
            }
          }
        }
      },
      toServerJSON: function() {
        if (!this.attrWhitelist) {
          return console.log("please add attrWhiteList in model for sync support");
        }
        return _.pick(this.attributes, this.attrWhitelist.concat(this.defaultAttributes));
      }
    });
  });

}).call(this);
