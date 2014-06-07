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
        if (options && options.sync) {
          return swipy.sync.handleModelForSync(this, attrs);
        }
      },
      toServerJSON: function(attrList) {
        var json, key, value;
        if (!this.attrWhitelist) {
          return console.log("please add attrWhiteList in model for sync support");
        }
        if (!attrList) {
          attrList = this.attrWhitelist.concat(this.defaultAttributes);
        }
        json = _.pick(this.attributes, attrList);
        for (key in json) {
          value = json[key];
          if (_.isDate(value)) {
            json[key] = {
              "__type": "Date",
              "iso": value
            };
          }
        }
        return json;
      },
      updateFromServerObj: function(obj) {
        if (!this.id) {
          this.id = obj.objectId;
        }
        if (obj.deleted) {
          return this.set("deleted", obj.deleted);
        }
      }
    });
  });

}).call(this);
