(function() {
  define(["underscore", "backbone", "gsap", "timelinelite", "text!templates/task.html"], function(_, Backbone, TweenLite, TimelineLite, TaskTmpl) {
    return Parse.View.extend({
      tagName: "li",
      initialize: function() {
        _.bindAll(this, "onSelected", "setBounds", "toggleSelected", "togglePriority", "edit", "handleAction");
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
        this.$el.on("click", ".priority", this.togglePriority);
        this.$el.on("dblclick", ".todo-content", this.edit);
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
      togglePriority: function(e) {
        e.stopPropagation();
        return this.model.togglePriority();
      },
      handleAction: function(e) {
        var selectedTasks, task, trigger, _i, _len,
          _this = this;
        trigger = [this.model];
        selectedTasks = swipy.todos.filter(function(m) {
          return m.get("selected");
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
      edit: function(e) {
        if (e.target.className === "priority") {
          return false;
        }
        return swipy.router.navigate("edit/" + this.model.id, true);
      },
      render: function() {
        if (this.template == null) {
          return this;
        }
        this.$el.html(this.template(this.model.toJSON()));
        this.$el.attr("data-id", this.model.id);
        this.afterRender();
        return this;
      },
      afterRender: function() {},
      remove: function() {
        this.cleanUp();
        return this.$el.remove();
      },
      customCleanUp: function() {},
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
          left: this.$el.outerWidth(),
          ease: Power2.easeInOut
        });
        if (fadeOut) {
          timeline.to(this.$el, 0.2, {
            alpha: 0,
            height: 0
          }, "-=0.1");
        }
        return dfd.promise();
      },
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
          left: 0 - this.$el.outerWidth(),
          ease: Power2.easeInOut
        });
        if (fadeOut) {
          timeline.to(this.$el, 0.2, {
            alpha: 0,
            height: 0
          }, "-=0.1");
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
        $(window).off("resize", this.setBounds);
        this.$el.off();
        this.undelegateEvents();
        this.stopListening();
        return this.customCleanUp();
      }
    });
  });

}).call(this);
