(function() {
  define(["underscore", "backbone", "text!templates/task-editor.html", "view/editor/TagEditor"], function(_, Backbone, TaskEditorTmpl, TagEditor) {
    return Backbone.View.extend({
      tagName: "article",
      className: "task-editor",
      events: {
        "click .save": "save",
        "click time": "reschedule",
        "click .repeat-picker a": "setRepeat",
        "blur .title input": "updateTitle",
        "blur .notes textarea": "updateNotes"
      },
      initialize: function() {
        $("body").addClass("edit-mode");
        this.setTemplate();
        this.render();
        return this.listenTo(this.model, "change:schedule change:repeatOption", this.render);
      },
      setTemplate: function() {
        return this.template = _.template(TaskEditorTmpl);
      },
      killTagEditor: function() {
        if (this.tagEditor != null) {
          this.tagEditor.cleanUp();
          return this.tagEditor.remove();
        }
      },
      createTagEditor: function() {
        return this.tagEditor = new TagEditor({
          el: this.$el.find(".icon-tags"),
          model: this.model
        });
      },
      setStateClass: function() {
        return this.$el.removeClass("active scheduled completed").addClass(this.model.getState());
      },
      render: function() {
        this.$el.html(this.template(this.model.toJSON()));
        this.setStateClass();
        this.killTagEditor();
        this.createTagEditor();
        return this.el;
      },
      save: function() {
        var opts,
          _this = this;
        opts = {
          success: function() {
            return swipy.router.back();
          },
          error: function() {
            return swipy.errors["throw"]("Something went wrong. Please try again in a little bit.", arguments);
          }
        };
        return this.model.save({}, opts);
      },
      reschedule: function() {
        return Backbone.trigger("show-scheduler", [this.model]);
      },
      transitionInComplete: function() {},
      setRepeat: function(e) {
        return this.model.set("repeatOption", $(e.currentTarget).data("option"));
      },
      updateTitle: function() {
        return this.model.set("title", this.getTitle());
      },
      updateNotes: function() {
        return this.model.set("notes", this.getNotes());
      },
      getTitle: function() {
        return this.$el.find(".title input").val();
      },
      getNotes: function() {
        return this.$el.find(".notes textarea").val();
      },
      remove: function() {
        $("body").removeClass("edit-mode");
        this.undelegateEvents();
        this.stopListening();
        return this.$el.remove();
      }
    });
  });

}).call(this);
