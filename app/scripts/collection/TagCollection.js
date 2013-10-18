(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.Collection.extend({
      initialize: function() {
        this.getTagsFromTasks();
        return this.on("remove", this.handleTagDeleted, this);
      },
      getTagsFromTasks: function() {
        var tagObjs, tagname, tags;
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
        tagObjs = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = tags.length; _i < _len; _i++) {
            tagname = tags[_i];
            _results.push({
              title: tagname
            });
          }
          return _results;
        })();
        return this.reset(tagObjs);
      },
      handleTagDeleted: function(model) {
        var affectedTasks, oldTags, tagName, task, _i, _len, _results;
        tagName = model.get("title");
        affectedTasks = swipy.todos.filter(function(m) {
          return m.has("tags") && _.contains(m.get("tags"), tagName);
        });
        _results = [];
        for (_i = 0, _len = affectedTasks.length; _i < _len; _i++) {
          task = affectedTasks[_i];
          oldTags = task.get("tags");
          task.unset("tags", {
            silent: true
          });
          _results.push(task.set("tags", _.without(oldTags, tagName)));
        }
        return _results;
      }
    });
  });

}).call(this);
