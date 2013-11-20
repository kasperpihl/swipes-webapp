(function() {
  define(["underscore", "backbone", "view/Overlay", "model/TagModel", "text!templates/tags-editor-overlay.html"], function(_, Backbone, Overlay, TagModel, TagsEditorOverlayTmpl) {
    return Overlay.extend({
      className: 'overlay tags-editor',
      events: {
        "click .overlay-bg": "destroy",
        "click .save": "destroy",
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
        var modelList, stringLists, tagLists, _i, _len;
        tagLists = _.invoke(this.options.models, "get", "tags");
        if (_.contains(tagLists, null)) {
          return [];
        }
        stringLists = [];
        for (_i = 0, _len = tagLists.length; _i < _len; _i++) {
          modelList = tagLists[_i];
          stringLists.push(_.invoke(modelList, "get", "title"));
        }
        return _.intersection.apply(_, stringLists);
      },
      getTagFromName: function(tagName) {
        var tag;
        tag = swipy.tags.findWhere({
          title: tagName
        });
        if (tag) {
          return tag;
        }
      },
      render: function() {
        this.$el.html(this.template({
          allTags: swipy.tags.toJSON(),
          tagsAppliedToAll: this.getTagsAppliedToAll()
        }));
        console.log("Rendering tag overlay");
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
        return Backbone.trigger("redraw-sortable-list");
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
        var model, tag, _i, _len, _ref,
          _this = this;
        if (addToCollection == null) {
          addToCollection = true;
        }
        if (addToCollection && _.contains(swipy.tags.pluck("title"), tagName)) {
          return alert("That tag already exists");
        } else {
          tag = this.getTagFromName(tagName);
          if (!tag && addToCollection) {
            tag = new TagModel({
              title: tagName
            });
          }
          if (addToCollection) {
            console.log("Adding tag to collection");
            swipy.tags.add(tag);
            tag.save().then(function() {
              var model, _i, _len, _ref, _results;
              console.log("Added to col. Now adding tag to model");
              _ref = _this.options.models;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                model = _ref[_i];
                _results.push(_this.addTagToModel(tag, model));
              }
              return _results;
            });
          } else {
            _ref = this.options.models;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              model = _ref[_i];
              this.addTagToModel(tag, model);
            }
          }
          return this.render();
        }
      },
      modelHasTag: function(model, tag) {
        var tagName;
        tagName = tag.get("title");
        return !!_.filter(model.get("tag"), function(t) {
          return t.get("title") === tagName;
        }).length;
      },
      addTagToModel: function(tag, model) {
        var tags;
        if (model.has("tags")) {
          if (this.modelHasTag(model, tag)) {
            return;
          }
          tags = model.get("tags");
          tags.push(tag);
          model.unset("tags", {
            silent: true
          });
          return model.save("tags", tags);
        } else {
          return model.save("tags", [tag]);
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
          model.save("tags", newTags);
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
