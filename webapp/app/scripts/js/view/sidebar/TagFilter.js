(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      events: {
        "click li:not(.delete)": "handleClickTag",
        "click .delete": "toggleDeleteMode",
        "click .remove": "removeTag"
      },
      initialize: function() {
        var _this = this;
        this.render = _.throttle(this.render, 500);
        this.listenTo(swipy.tags, "add remove reset", this.render);
        this.listenTo(Backbone, "apply-filter remove-filter", this.handleFilterChange);
        this.listenTo(Backbone, "navigate/view", function() {
          return _.defer(function() {
            return _this.render();
          });
        });
        this.listenTo(swipy.todos, "change:tags", this.render);
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
      handleClickTag: function(e) {
        if (this.deleteMode) {
          return this.removeTag(e);
        } else {
          return this.toggleFilter(e);
        }
      },
      toggleDeleteMode: function(e) {
        e.stopPropagation();
        if (this.deleteMode) {
          this.deleteMode = false;
        } else {
          this.deleteMode = true;
        }
        return this.$el.toggleClass("delete-mode", this.deleteMode);
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
        tagName = $.trim($(e.currentTarget).text());
        tag = swipy.tags.findWhere({
          title: tagName
        });
        wasSelected = $(e.currentTarget).hasClass("selected");
        if (tag && confirm("Are you sure you want to permenently delete this tag?")) {
          swipy.tags.remove(tag);
          tag.deleteObj();
          if (wasSelected) {
            return Backbone.trigger("remove-filter", "tag", tagName);
          }
        }
      },
      getTagsForCurrentTasks: function() {
        var activeList, model, models, tagName, tags, _i, _j, _len, _len1, _ref;
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
            _ref = model.getTagStrList();
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              tagName = _ref[_j];
              tags.push(tagName);
            }
          }
        }
        return _.unique(tags);
      },
      getValidatedTags: function() {
        return swipy.tags.pluck("title");
        if ((swipy.filter != null) && swipy.filter.tagsFilter.length) {
          return swipy.tags.getSiblings(swipy.filter.tagsFilter, false);
        } else {
          return this.getTagsForCurrentTasks();
        }
      },
      render: function() {
        var list, tag, tags, _i, _len;
        list = this.$el.find(".rounded-tags");
        list.empty();
        tags = this.getValidatedTags();
        tags = _.sortBy(tags, function(tag) {
          return tag.toLowerCase();
        });
        for (_i = 0, _len = tags.length; _i < _len; _i++) {
          tag = tags[_i];
          this.renderTag(tag, list);
        }
        if (tags.length) {
          this.renderDeleteButton(list);
        }
        if (this.deleteMode) {
          this.$el.toggleClass("delete-mode", true);
        }
        return this;
      },
      renderTag: function(tagName, list) {
        if ((swipy.filter != null) && _.contains(swipy.filter.tagsFilter, tagName)) {
          return list.append("<li class='selected'>" + tagName + "</li>");
        } else {
          return list.append("<li>" + tagName + "</li>");
        }
      },
      renderDeleteButton: function(list) {
        return list.append("<li class='delete'><a href='JavaScript:void(0);' title='Delete tags'><span class='icon-trashcan'></span></a></li>");
      },
      destroy: function() {
        this.stopListening();
        return this.undelegateEvents();
      }
    });
  });

}).call(this);
