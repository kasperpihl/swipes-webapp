(function() {
  define(["backbone"], function() {
    return Backbone.Model.extend({
      className: "BaseModel",
      sync: function() {
        return true;
      },
      handleForSync: function(key, val, options) {
        var att, attrs, valOfAtt, _results;
        attrs = {};
        if (key === null || typeof key === 'object') {
          attrs = key;
          options = val;
        } else {
          attrs[key] = val;
        }
        if (options) {
          if (options.sync) {
            swipy.sync.handleModelForSync(this, attrs);
          }
          if (options.fire) {
            _results = [];
            for (att in attrs) {
              valOfAtt = attrs[att];
              _results.push(console.log(att));
            }
            return _results;
          }
        }
      }
    });
  });

}).call(this);
