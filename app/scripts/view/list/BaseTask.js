(function() {
  define(["underscore", "backbone", "gsap", "timelinelite", "text!templates/task.html"], function(_, Backbone, TweenLite, TimelineLite, TaskTmpl) {
    return Backbone.View.extend({
      tagName: "li",
      initialize: function() {
        _.bindAll(this, "onSelected", "setBounds", "toggleSelected", "edit", "handleAction");
        this.listenTo(this.model, "change:tags change:timeStr", this.render, this);
        this.listenTo(this.model, "change:selected", this.onSelected);
        $(window).on("resize", this.setBounds);
        this.setTemplate();
        this.init();
        this.render();
        return this.bindEvents();
      },
      bindEvents: function() {
        this.$el.on("click", ".todo-content", this.toggleSelected);
        this.$el.on("dblclick", "h2", this.edit);
        return this.$el.on("click", ".action", this.handleAction);
      },
      setTemplate: function() {
        return this.template = _.template(TaskTmpl);
      },
      setBounds: function() {
        return this.bounds = this.el.getClientRects()[0];
      },
      init: function() {},
      toggleSelected: function() {
        var currentlySelected;
        currentlySelected = this.model.get("selected") || false;
        return this.model.set("selected", !currentlySelected);
      },
      handleAction: function(e) {
        var selectedTasks, task, trigger, _i, _len,
          _this = this;
        trigger = [this.model];
        selectedTasks = swipy.todos.where({
          selected: true
        });
        if (selectedTasks.length) {
          selectedTasks = _.reject(selectedTasks, function(m) {
            return m.cid === _this.model.cid;
          });
          for (_i = 0, _len = selectedTasks.length; _i < _len; _i++) {
            task = selectedTasks[_i];
            trigger.push(task);
          }
        }
        if ($(e.currentTarget).hasClass("schedule")) {
          return Backbone.trigger("schedule-task", trigger);
        } else if ($(e.currentTarget).hasClass("complete")) {
          return Backbone.trigger("complete-task", trigger);
        } else if ($(e.currentTarget).hasClass("todo")) {
          return Backbone.trigger("todo-task", trigger);
        }
      },
      onSelected: function(model, selected) {
        return this.$el.toggleClass("selected", selected);
      },
      edit: function() {
        return swipy.router.navigate("edit/" + this.model.cid, true);
      },
      render: function() {
        if (this.template == null) {
          return this.el;
        }
        this.$el.html(this.template(this.model.toJSON()));
        return this.el;
      },
      remove: function() {
        this.cleanUp();
        return this.$el.remove();
      },
      customCleanUp: function() {},
      swipeLeft: function(className, fadeOut) {
        var content, dfd, timeline;
        if (fadeOut == null) {
          fadeOut = true;
        }
        dfd = new $.Deferred();
        content = this.$el.find(".todo-content");
        if (className) {
          this.$el.addClass(className);
        }
        timeline = new TimelineLite({
          onComplete: dfd.resolve
        });
        timeline.to(content, 0.3, {
          left: this.$el.outerWidth()
        });
        if (fadeOut) {
          timeline.to(this.$el, 0.4, {
            alpha: 0
          }, "-=0.2");
        }
        return dfd.promise();
      },
      swipeRight: function(className, fadeOut) {
        var content, dfd, timeline;
        if (fadeOut == null) {
          fadeOut = true;
        }
        dfd = new $.Deferred();
        content = this.$el.find(".todo-content");
        if (className) {
          this.$el.addClass(className);
        }
        timeline = new TimelineLite({
          onComplete: dfd.resolve
        });
        timeline.to(content, 0.3, {
          left: 0 - this.$el.outerWidth()
        });
        if (fadeOut) {
          timeline.to(this.$el, 0.4, {
            alpha: 0
          }, "-=0.2");
        }
        return dfd.promise();
      },
      reset: function() {
        var content;
        content = this.$el.find(".todo-content");
        this.$el.removeClass("scheduled completed todo");
        content.css("left", "");
        return this.$el.css("opacity", "");
      },
      cleanUp: function() {
        $(window).off();
        this.$el.off();
        this.undelegateEvents();
        this.stopListening();
        return this.customCleanUp();
      }
    });
  });

}).call(this);
