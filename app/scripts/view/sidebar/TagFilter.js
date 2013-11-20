(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Parse.View.extend({
      events: {
        "click li": "toggleFilter",
        "click .remove": "removeTag"
      },
      initialize: function() {
        var _this = this;
        this.listenTo(swipy.tags, "add remove reset", this.render);
        this.listenTo(Backbone, "apply-filter remove-filter", this.handleFilterChange);
        this.listenTo(Backbone, "navigate/view", function() {
          return _.defer(function() {
            return _this.render();
          });
        });
        return this.render();
      },
      handleFilterChange: function(type) {
        var _this = this;
        return _.defer(function() {
          if (type === "tag") {
            return _this.render();
          }
        });
      },
      toggleFilter: function(e) {
        var el, tag;
        tag = $.trim($(e.currentTarget).text());
        el = $(e.currentTarget);
        if (!el.hasClass("selected")) {
          return Backbone.trigger("apply-filter", "tag", tag);
        } else {
          return Backbone.trigger("remove-filter", "tag", tag);
        }
      },
      removeTag: function(e) {
        var tag, tagName, wasSelected;
        e.stopPropagation();
        tagName = $.trim($(e.currentTarget.parentNode).text());
        tag = swipy.tags.findWhere({
          title: tagName
        });
        wasSelected = $(e.currentTarget.parentNode).hasClass("selected");
        if (tag && confirm("Are you sure you want to permenently delete this tag?")) {
          return tag.destroy({
            success: function(model, response) {
              swipy.todos.remove(model);
              if (wasSelected) {
                return Backbone.trigger("remove-filter", "tag", tagName);
              }
            },
            error: function(model, response) {
              alert("Something went wrong trying to delete the tag '" + (model.get('title')) + "' please try again.");
              return console.warn("Error deleting tag — Response: ", response);
            }
          });
        }
      },
      getTagsForCurrentTasks: function() {
        var activeList, model, models, tag, tags, _i, _j, _len, _len1, _ref;
        tags = [];
        activeList = swipy.todos.getActiveList();
        switch (activeList) {
          case "todo":
            models = swipy.todos.getActive();
            break;
          case "scheduled":
            models = swipy.todos.getScheduled();
            break;
          default:
            models = swipy.todos.getCompleted();
        }
        for (_i = 0, _len = models.length; _i < _len; _i++) {
          model = models[_i];
          if (model.has("tags")) {
            _ref = model.get("tags");
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              tag = _ref[_j];
              if (swipy.tags.validateTag(tag)) {
                tags.push(tag);
              }
            }
          }
        }
        return _.unique(tags);
      },
      getValidatedTags: function() {
        if ((swipy.filter != null) && swipy.filter.tagsFilter.length) {
          return swipy.tags.getSiblings(swipy.filter.tagsFilter, false);
        } else {
          return this.getTagsForCurrentTasks();
        }
      },
      render: function() {
        var list, tag, _i, _len, _ref;
        list = this.$el.find(".rounded-tags");
        list.empty();
        _ref = this.getValidatedTags();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          tag = _ref[_i];
          this.renderTag(tag, list);
        }
        return this;
      },
      renderTag: function(tag, list) {
        var tagName;
        tagName = tag.get("title");
        if ((swipy.filter != null) && _.contains(swipy.filter.tagsFilter, tagName)) {
          return list.append("<li class='selected'>" + tagName + "</li>");
        } else {
          return list.append("<li>" + tagName + "</li>");
        }
      },
      destroy: function() {
        this.stopListening();
        return this.undelegateEvents();
      }
    });
  });

}).call(this);
