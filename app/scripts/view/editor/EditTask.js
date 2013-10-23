(function() {
  define(["underscore", "backbone", "text!templates/edit-task.html", "view/editor/TagEditor"], function(_, Backbone, TaskTmpl, TagEditor) {
    return Backbone.View.extend({
      tagName: "article",
      className: "task-editor",
      events: {
        "click .cancel": "back",
        "click .save": "save"
      },
      initialize: function() {
        this.$el.addClass(this.model.getState());
        this.setTemplate();
        return this.render();
      },
      setTemplate: function() {
        return this.template = _.template(TaskTmpl);
      },
      createTagEditor: function() {
        return this.tagEditor = new TagEditor({
          el: this.$el.find(".icon-tags"),
          model: this.model
        });
      },
      render: function() {
        this.$el.html(this.template(this.model.toJSON()));
        this.createTagEditor();
        return this.el;
      },
      back: function() {
        var prevRoute;
        if (swipy.router.history.length > 1) {
          prevRoute = swipy.router.history[swipy.router.history.length - 2];
          return swipy.router.navigate(prevRoute, true);
        } else {
          return location.hash = "";
        }
      },
      save: function() {
        var atts, opts,
          _this = this;
        atts = {
          title: this.getTitle(),
          notes: this.getNotes()
        };
        console.log("Saving ", atts);
        opts = {
          success: function() {
            return _this.back();
          },
          error: function() {
            return swipy.errors["throw"]("Something went wrong. Please try again in a little bit.", arguments);
          }
        };
        return this.model.save(atts, opts);
      },
      transitionInComplete: function() {
        return console.log("Edit view finished transitionIn");
      },
      getTitle: function() {
        return this.$el.find(".title input").val();
      },
      getNotes: function() {
        return this.$el.find(".notes textarea").val();
      }
    });
  });

}).call(this);
