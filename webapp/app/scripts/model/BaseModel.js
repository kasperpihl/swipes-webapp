(function() {
  define([], function() {
    return Parse.Object.extend({
      className: "BaseModel",
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
