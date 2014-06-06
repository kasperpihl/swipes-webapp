(function() {
  define(["backbone"], function() {
    return Backbone.Model.extend({
      className: "BaseModel",
      sync: function() {
        return false;
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
          console.log(options);
          console.log(attrs);
          return swipy.sync.handleModelForSync(this, attrs);
        }
      }
    });
  });

}).call(this);
