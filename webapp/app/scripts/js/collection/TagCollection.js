(function() {
  define(["underscore", "js/model/TagModel", "backbone.localStorage"], function(_, TagModel) {
    return Backbone.Collection.extend({
      model: TagModel,
      localStorage: new Backbone.LocalStorage("TagCollection"),
      initialize: function() {
        this.on("remove", this.handleTagDeleted);
        this.on("add", this.handleAddTag, this);
        return this.on("reset", function() {
          var m, removeThese, _i, _len, _results;
          removeThese = (function() {
            var _i, _len, _ref, _results;
            _ref = this.models;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              m = _ref[_i];
              if (m.get("deleted")) {
                _results.push(m);
              }
            }
            return _results;
          }).call(this);
          _results = [];
          for (_i = 0, _len = removeThese.length; _i < _len; _i++) {
            m = removeThese[_i];
            _results.push(this.remove(m, {
              silent: true
            }));
          }
          return _results;
        });
      },
      handleObjects: function(objects) {
        var model, obj, _i, _len, _results;
        if (!objects || objects.length === 0) {
          return false;
        }
        _results = [];
        for (_i = 0, _len = objects.length; _i < _len; _i++) {
          obj = objects[_i];
          model = new this.model(obj);
          _results.push(console.log(model));
        }
        return _results;
      },
      getTagsFromTasks: function() {
        var m, tag, tags, _i, _j, _len, _len1, _ref, _ref1;
        tags = [];
        _ref = swipy.todos.models;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          m = _ref[_i];
          if (m.has("tags")) {
            _ref1 = m.get("tags");
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              tag = _ref1[_j];
              if (this.validateTag(tag)) {
                if (!_.findWhere(tags, {
                  cid: tag.cid
                })) {
                  tags.push(tag);
                }
              }
            }
          }
        }
        this.reset(tags);
        return this.saveNewTags();
      },
      getTagByName: function(tagName) {
        var result;
        tagName = tagName.toLowerCase();
        result = this.filter(function(tag) {
          return tag.get("title").toLowerCase() === tagName;
        });
        if (result.length) {
          return result[0];
        } else {
          return void 0;
        }
      },
      saveNewTags: function() {
        var model, _i, _len, _ref, _results;
        _ref = this.models;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          model = _ref[_i];
          if (model.isNew()) {
            _results.push(swipy.queue.add(model.save()));
          }
        }
        return _results;
      },
      handleAddTag: function(model) {
        if (!this.validateTag(model)) {
          return this.remove(model, {
            silent: true
          });
        }
      },
      validateTag: function(model) {
        if (!model.has("title")) {
          return false;
        }
        if (this.where({
          title: model.get("title")
        }).length > 1) {
          return false;
        }
        return true;
      },
      /**
      		 * Looks at a tag (Or an array of tags), finds all the tasks that are tagged with those tags.
      		 * (If multiple tags are passed, the tasks must have all of the tags applied to them)
      		 * The method then finds and returns a list of other tags that those tasks have been tagged with.
      		 *
      		 * For example, if we have three tasks like this
      		 * Task 1
      		 * 		- tags: Nina
      		 * Task 2
      		 * 		- tagged: Nina, Pinta
      		 * Task 3
      		 * 		- tagged: Nina, Pinta, Santa-Maria
      		 *
      		 * If you call getSibling( "Nina" ) you will get
      		 * [ "Pinta", "Santa-Maria" ] as the return value.
      		 *
      		 *
      		 * @param  {String/Array} tags a string or an array of strings (Tagnames)
      		 * @param  {Boolean} excludeOriginals if false, the original tags, the ones the siblings are based on, will be included in the result
      		 *
      		 * @return {array}     an array with the results. No results will return an empty array
      */

      getSiblings: function(tags, excludeOriginals) {
        var result, task, _i, _len, _ref;
        if (excludeOriginals == null) {
          excludeOriginals = true;
        }
        if (typeof tags !== "object") {
          tags = [tags];
        }
        result = [];
        _ref = swipy.todos.getTasksTaggedWith(tags);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          task = _ref[_i];
          result.push(_.invoke(task.get("tags"), "get", "title"));
        }
        result = _.flatten(result);
        result = _.unique(result);
        if (excludeOriginals) {
          return _.reject(result, function(tagName) {
            return _.contains(tags, tagName);
          });
        } else {
          return result;
        }
      },
      handleTagDeleted: function(model) {
        var affectedTasks, newTags, oldTags, tagName, task, _i, _len, _results;
        tagName = model.get("title");
        affectedTasks = swipy.todos.filter(function(m) {
          return m.has("tags") && _.contains(m.getTagStrList(), tagName);
        });
        console.log("tag");
        _results = [];
        for (_i = 0, _len = affectedTasks.length; _i < _len; _i++) {
          task = affectedTasks[_i];
          oldTags = task.get("tags");
          task.unset("tags", {
            silent: true
          });
          newTags = _.reject(oldTags, function(tag) {
            return tag.get("title") === model.get("title");
          });
          _results.push(task.set("tags", newTags));
        }
        return _results;
      },
      destroy: function() {
        return this.off(null, null, this);
      }
    });
  });

}).call(this);
