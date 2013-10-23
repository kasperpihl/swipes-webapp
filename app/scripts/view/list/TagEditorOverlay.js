(function() {
  define(["underscore", "backbone", "view/Overlay", "text!templates/tags-editor-overlay.html"], function(_, Backbone, Overlay, TagsEditorOverlayTmpl) {
    return Overlay.extend({
      className: 'overlay tags-editor',
      events: {
        "click .overlay-bg": "hide",
        "click .save": "hide",
        "click .rounded-tags li:not(.tag-input)": "toggleTag",
        "submit form": "createTag"
      },
      initialize: function() {
        Overlay.prototype.initialize.apply(this, arguments);
        this.showClassName = "tags-editor-open";
        this.hideClassName = "hide-tags-editor";
        return this.render();
      },
      bindEvents: function() {
        _.bindAll(this, "handleResize");
        return $(window).on("resize", this.handleResize);
      },
      setTemplate: function() {
        return this.template = _.template(TagsEditorOverlayTmpl);
      },
      getTagsAppliedToAll: function() {
        var tagLists;
        tagLists = _.invoke(this.options.models, "get", "tags");
        if (_.contains(tagLists, null)) {
          return [];
        }
        return _.intersection.apply(_, tagLists);
      },
      render: function() {
        this.$el.html(this.template({
          allTags: swipy.tags.toJSON(),
          tagsAppliedToAll: this.getTagsAppliedToAll()
        }));
        if (!this.addedToDom) {
          $("body").append(this.$el);
          this.addedToDom = true;
        }
        this.show();
        this.handleResize();
        this.$el.find(".tag-input input").focus();
        return this;
      },
      afterHide: function() {
        return this.destroy();
      },
      toggleTag: function(e) {
        var remove, tag, target;
        target = $(e.currentTarget);
        remove = target.hasClass("selected");
        tag = target.text();
        console.log("Toggle " + tag + " ", !remove);
        if (remove) {
          return this.removeTagFromModels(tag);
        } else {
          return this.addTagToModels(tag, false);
        }
      },
      createTag: function(e) {
        var tagName;
        e.preventDefault();
        tagName = this.$el.find("form.add-tag input").val();
        if (tagName === "") {
          return;
        }
        return this.addTagToModels(tagName);
      },
      addTagToModels: function(tagName, addToCollection) {
        var model, _i, _len, _ref;
        if (addToCollection == null) {
          addToCollection = true;
        }
        if (addToCollection && _.contains(swipy.tags.pluck("title"), tagName)) {
          return alert("That tag already exists");
        } else {
          _ref = this.options.models;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            model = _ref[_i];
            this.addTagToModel(tagName, model);
          }
          if (addToCollection) {
            swipy.tags.getTagsFromTasks();
          }
          return this.render();
        }
      },
      addTagToModel: function(tagName, model) {
        var tags;
        if (model.has("tags")) {
          tags = model.get("tags");
          if (_.contains(tags, tagName)) {
            return;
          }
          tags.push(tagName);
          model.unset("tags", {
            silent: true
          });
          return model.set("tags", tags);
        } else {
          return model.set("tags", [tagName]);
        }
      },
      removeTagFromModels: function(tag) {
        var model, newTags, tags, _i, _len, _ref;
        _ref = this.options.models;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          model = _ref[_i];
          tags = model.get("tags");
          newTags = _.without(tags, tag);
          model.unset("tags", {
            silent: true
          });
          model.set("tags", newTags);
        }
        return this.render();
      },
      handleResize: function() {
        var content, offset;
        if (!this.shown) {
          return;
        }
        content = this.$el.find(".overlay-content");
        offset = (window.innerHeight / 2) - (content.height() / 2);
        return content.css("margin-top", offset);
      },
      cleanUp: function() {
        $(window).off("resize", this.handleResize);
        return Overlay.prototype.cleanUp.apply(this, arguments);
      }
    });
  });

}).call(this);
