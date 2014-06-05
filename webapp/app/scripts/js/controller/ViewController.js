(function() {
  define(["underscore", "backbone", "gsap"], function(_, Backbone, TweenLite, EditTaskView) {
    var ViewController;
    return ViewController = (function() {
      function ViewController(opts) {
        this.init();
      }

      ViewController.prototype.init = function() {
        Backbone.on('navigate/view', this.goto, this);
        return Backbone.on('edit/task', this.editTask, this);
      };

      ViewController.prototype.goto = function(slug) {
        var _this = this;
        return this.loadView(slug).then(function(View) {
          var newView;
          newView = new View({
            el: "ol.todo-list." + slug
          });
          if (_this.currView != null) {
            return _this.transitionOut(_this.currView).then(function() {
              return _this.transitionIn(newView).then(function() {
                return newView.transitionInComplete.call(newView);
              });
            });
          } else {
            return _this.transitionIn(newView).then(function() {
              return newView.transitionInComplete.call(newView);
            });
          }
        });
      };

      ViewController.prototype.editTask = function(taskId) {
        var m, model, _i, _len, _ref,
          _this = this;
        _ref = swipy.todos.models;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          m = _ref[_i];
          if (m.id === taskId) {
            model = m;
          }
        }
        if (model == null) {
          swipy.router.navigate("", true);
          return console.warn("Model with id " + taskId + " couldn't be found — Returning to root");
        }
        if (this.currView != null) {
          return this.transitionOut(this.currView).then(function() {
            return _this.loadTaskEditor(model);
          });
        } else {
          return this.loadTaskEditor(model);
        }
      };

      ViewController.prototype.loadTaskEditor = function(model) {
        var _this = this;
        return require(["js/view/editor/TaskEditor"], function(EditTaskView) {
          var editView;
          editView = new EditTaskView({
            model: model
          });
          $("#main-content").prepend(editView.el);
          return _this.transitionIn(editView).then(function() {
            var _ref;
            return (_ref = editView.transitionInComplete) != null ? _ref.call(editView) : void 0;
          });
        });
      };

      ViewController.prototype.loadView = function(slug) {
        var dfd;
        dfd = new $.Deferred();
        if (slug === "scheduled") {
          require(["js/view/Scheduled"], function(View) {
            return dfd.resolve(View);
          });
        } else if (slug === "completed") {
          require(["js/view/Completed"], function(View) {
            return dfd.resolve(View);
          });
        } else {
          require(["js/view/Todo"], function(View) {
            return dfd.resolve(View);
          });
        }
        return dfd.promise();
      };

      ViewController.prototype.transitionOut = function(view) {
        var dfd, opts,
          _this = this;
        dfd = new $.Deferred();
        opts = {
          alpha: 0,
          onComplete: function() {
            view.$el.addClass("hidden");
            view.remove();
            return dfd.resolve();
          }
        };
        TweenLite.to(view.$el, 0, opts);
        return dfd.promise();
      };

      ViewController.prototype.transitionIn = function(view) {
        var dfd, opts;
        dfd = new $.Deferred();
        opts = {
          alpha: 1,
          onComplete: dfd.resolve
        };
        view.$el.removeClass("hidden");
        TweenLite.fromTo(view.$el, 0, {
          alpha: 0
        }, opts);
        this.currView = view;
        return dfd.promise();
      };

      ViewController.prototype.destroy = function() {
        var _ref;
        if ((_ref = this.currView) != null) {
          _ref.remove();
        }
        return Backbone.off(null, null, this);
      };

      return ViewController;

    })();
  });

}).call(this);
