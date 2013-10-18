(function() {
  define(["underscore", "backbone", "view/Overlay", "text!templates/tags-editor-overlay.html"], function(_, Backbone, Overlay, TagsEditorOverlayTmpl) {
    return Overlay.extend({
      className: 'overlay tags-editor',
      events: {
        "click .overlay-bg": "hide",
        "click .close": "hide"
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
        console.log("Shared tags: ", this.getTagsAppliedToAll());
        this.$el.html(this.template({
          allTags: swipy.tags.toJSON(),
          tagsAppliedToAll: this.getTagsAppliedToAll()
        }));
        $("body").append(this.$el);
        this.show();
        return this;
      },
      afterShow: function() {
        return this.handleResize();
      },
      afterHide: function() {
        return this.destroy();
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
        $(window).off();
        return Overlay.prototype.cleanUp.apply(this, arguments);
      }
    });
  });

}).call(this);
