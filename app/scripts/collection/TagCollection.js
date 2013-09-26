(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.Collection.extend({
      initialize: function() {
        return this.getTagsFromTasks();
      },
      getTagsFromTasks: function() {
        var tagname, tags, _i, _len, _results;
        tags = [];
        swipy.todos.each(function(m) {
          var tag, _i, _len, _ref, _results;
          if (m.has("tags")) {
            _ref = m.get("tags");
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              tag = _ref[_i];
              _results.push(tags.push(tag));
            }
            return _results;
          }
        });
        tags = _.unique(tags);
        _results = [];
        for (_i = 0, _len = tags.length; _i < _len; _i++) {
          tagname = tags[_i];
          _results.push(this.add({
            title: tagname
          }));
        }
        return _results;
      }
    });
  });

}).call(this);
